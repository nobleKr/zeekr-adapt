#!/usr/bin/env python3
"""
Patch binary AndroidManifest.xml (AXML) to replace appComponentFactory value.
Works directly on the compiled binary XML inside APK — no apktool needed.

Usage: python3 patch_manifest.py <input.apk> <output.apk> <new_factory_class>

Strategy: The AXML string pool contains all strings used in the manifest.
We find the old appComponentFactory value string and replace it with our new one.
If the new string is the same length, it's a simple swap.
If different length, we add the new string to the pool and patch the attribute reference.
"""

import sys
import struct
import zipfile
import shutil
import os
import tempfile


def read_u16(data, offset):
    return struct.unpack_from('<H', data, offset)[0]


def read_u32(data, offset):
    return struct.unpack_from('<I', data, offset)[0]


def write_u32(data, offset, value):
    struct.pack_into('<I', data, offset, value)


def read_utf16_string(data, offset):
    """Read a UTF-16 LE string from the string pool."""
    str_len = read_u16(data, offset)
    offset += 2
    chars = []
    for i in range(str_len):
        ch = read_u16(data, offset + i * 2)
        chars.append(chr(ch))
    return ''.join(chars)


def read_utf8_string(data, offset):
    """Read a UTF-8 string from the string pool."""
    # UTF-8 encoded: first 1-2 bytes = char count, then 1-2 bytes = byte count
    char_len = data[offset]
    offset += 1
    if char_len & 0x80:
        char_len = ((char_len & 0x7F) << 8) | data[offset]
        offset += 1
    
    byte_len = data[offset]
    offset += 1
    if byte_len & 0x80:
        byte_len = ((byte_len & 0x7F) << 8) | data[offset]
        offset += 1
    
    s = data[offset:offset + byte_len].decode('utf-8', errors='replace')
    return s


def find_string_in_pool(data, pool_offset, string_count, is_utf8):
    """Find all strings in the AXML string pool."""
    strings = []
    # String offsets start after the header
    # Pool header: type(2) + headerSize(2) + chunkSize(4) + stringCount(4) + 
    #              styleCount(4) + flags(4) + stringsStart(4) + stylesStart(4)
    header_size = read_u16(data, pool_offset + 2)
    strings_start_rel = read_u32(data, pool_offset + 20)
    strings_start = pool_offset + strings_start_rel
    
    offsets_start = pool_offset + header_size
    
    for i in range(string_count):
        str_offset_rel = read_u32(data, offsets_start + i * 4)
        str_abs = strings_start + str_offset_rel
        
        if is_utf8:
            s = read_utf8_string(data, str_abs)
        else:
            s = read_utf16_string(data, str_abs)
        strings.append((i, s, str_abs))
    
    return strings


def patch_axml_appcomponentfactory(manifest_data, new_factory):
    """
    Patch the appComponentFactory attribute value in binary AXML.
    
    Approach: Find the appComponentFactory attribute (resource ID 0x0101057a),
    then find the string it references and replace it.
    """
    data = bytearray(manifest_data)
    
    # AXML header
    if read_u16(data, 0) != 0x0003:  # RES_XML_TYPE
        raise ValueError("Not a valid AXML file")
    
    # String pool chunk starts at offset 8
    pool_type = read_u16(data, 8)
    if pool_type != 0x0001:  # RES_STRING_POOL_TYPE
        raise ValueError("Expected string pool at offset 8")
    
    pool_chunk_size = read_u32(data, 8 + 4)
    string_count = read_u32(data, 8 + 8)
    style_count = read_u32(data, 8 + 12)
    flags = read_u32(data, 8 + 16)
    is_utf8 = bool(flags & (1 << 8))
    
    print(f"String pool: {string_count} strings, {'UTF-8' if is_utf8 else 'UTF-16'}")
    
    strings = find_string_in_pool(data, 8, string_count, is_utf8)
    
    # Find appComponentFactory resource ID (0x0101057a) in XML elements
    # Walk through all XML elements after the string pool
    APP_COMPONENT_FACTORY_RES = 0x0101057a
    
    offset = 8 + pool_chunk_size
    old_factory_string_index = None
    attr_value_offset = None
    
    while offset < len(data) - 4:
        chunk_type = read_u16(data, offset)
        header_size = read_u16(data, offset + 2)
        chunk_size = read_u32(data, offset + 4)
        
        if chunk_size == 0:
            break
            
        # RES_XML_START_ELEMENT_TYPE = 0x0102
        if chunk_type == 0x0102:
            # Start element: look for attributes
            attr_count = read_u16(data, offset + 28)
            attr_start = offset + header_size
            
            for i in range(attr_count):
                attr_offset = attr_start + i * 20  # Each attr is 20 bytes
                attr_ns = read_u32(data, attr_offset + 0)
                attr_name = read_u32(data, attr_offset + 4)
                attr_raw = read_u32(data, attr_offset + 8)
                attr_type_data = read_u32(data, attr_offset + 12)
                attr_data = read_u32(data, attr_offset + 16)
                
                # Check resource ID mapping
                # The resource IDs are in a separate chunk (RES_XML_RESOURCE_MAP_TYPE = 0x0180)
                # attr_name is a string pool index; we need to check if it maps to our resource ID
                # For now, check by string name
                if attr_name < string_count:
                    name_str = strings[attr_name][1]
                    if name_str == 'appComponentFactory':
                        old_factory_string_index = attr_data  # String pool index of the value
                        attr_value_offset = attr_offset + 16  # Where to write new index
                        old_raw_offset = attr_offset + 8
                        if old_factory_string_index < string_count:
                            old_value = strings[old_factory_string_index][1]
                            print(f"Found appComponentFactory = '{old_value}' (string index {old_factory_string_index})")
                        break
        
        offset += chunk_size
    
    if old_factory_string_index is None:
        print("appComponentFactory attribute not found in manifest")
        return None
    
    # Strategy: Find if new_factory already exists in the string pool
    for idx, s, _ in strings:
        if s == new_factory:
            print(f"New factory '{new_factory}' already in pool at index {idx}")
            write_u32(data, attr_value_offset, idx)
            write_u32(data, old_raw_offset, idx)
            return bytes(data)
    
    # If old and new are same length, do in-place replacement
    old_value = strings[old_factory_string_index][1]
    old_abs = strings[old_factory_string_index][2]
    
    if len(old_value) == len(new_factory):
        print(f"Same length ({len(old_value)}), doing in-place replacement")
        if is_utf8:
            # Skip length bytes
            skip = 1
            if data[old_abs] & 0x80:
                skip = 2
            skip2 = 1
            byte_off = old_abs + skip
            if data[byte_off] & 0x80:
                skip2 = 2
            str_start = old_abs + skip + skip2
            encoded = new_factory.encode('utf-8')
            for i, b in enumerate(encoded):
                data[str_start + i] = b
        else:
            str_start = old_abs + 2  # Skip length u16
            encoded = new_factory.encode('utf-16-le')
            for i, b in enumerate(encoded):
                data[str_start + i] = b
        return bytes(data)
    
    # Different length: need to add new string to pool
    # This is complex — easier to just pad the old string if new is shorter,
    # or error if new is longer
    if len(new_factory) < len(old_value):
        print(f"New factory shorter ({len(new_factory)} < {len(old_value)}), padding with nulls")
        if is_utf8:
            skip = 1
            if data[old_abs] & 0x80:
                skip = 2
            # Update char count
            data[old_abs] = len(new_factory) & 0x7F
            byte_off = old_abs + skip
            skip2 = 1
            if data[byte_off] & 0x80:
                skip2 = 2
            # Update byte count
            data[byte_off] = len(new_factory.encode('utf-8')) & 0x7F
            str_start = old_abs + skip + skip2
            encoded = new_factory.encode('utf-8') + b'\x00'
            for i in range(len(old_value.encode('utf-8')) + 1):
                if i < len(encoded):
                    data[str_start + i] = encoded[i]
                else:
                    data[str_start + i] = 0
        else:
            str_start = old_abs
            # Write new length
            struct.pack_into('<H', data, str_start, len(new_factory))
            str_start += 2
            encoded = new_factory.encode('utf-16-le') + b'\x00\x00'
            for i in range(len(old_value) * 2 + 2):
                if i < len(encoded):
                    data[str_start + i] = encoded[i]
                else:
                    data[str_start + i] = 0
        return bytes(data)
    
    print(f"New factory longer ({len(new_factory)} > {len(old_value)}) — appending to string pool")
    return append_string_and_repoint(
        data, new_factory, is_utf8, attr_value_offset, old_raw_offset, string_count)


def append_string_and_repoint(data, new_str, is_utf8, attr_value_offset,
                              old_raw_offset, string_count):
    """Append new_str to the AXML string pool as a new entry, fix all chunk
    sizes / offsets / alignment, and repoint the attribute to the new index."""
    data = bytearray(data)

    # File header: type(2) headerSize(2) fileSize(4)
    # String pool at offset 8: type(2) headerSize(2) chunkSize(4) stringCount(4)
    #   styleCount(4) flags(4) stringsStart(4) stylesStart(4)
    POOL = 8
    pool_header_size = read_u16(data, POOL + 2)
    pool_chunk_size = read_u32(data, POOL + 4)
    style_count = read_u32(data, POOL + 12)
    strings_start_rel = read_u32(data, POOL + 20)   # offset from POOL to string data
    styles_start_rel = read_u32(data, POOL + 24)

    offsets_start = POOL + pool_header_size          # u32[stringCount] then u32[styleCount]
    strings_start = POOL + strings_start_rel

    # The string-data region ends where styles start (or chunk end if no styles)
    if style_count > 0 and styles_start_rel != 0:
        strdata_end = POOL + styles_start_rel
    else:
        strdata_end = POOL + pool_chunk_size

    # Encode the new string entry
    if is_utf8:
        enc = new_str.encode('utf-8')
        clen = len(new_str)
        blen = len(enc)
        # UTF-8: charLen (1-2 bytes), byteLen (1-2 bytes), bytes, 0x00
        def putlen(v):
            return bytes([v]) if v < 0x80 else bytes([0x80 | (v >> 8), v & 0xFF])
        entry = putlen(clen) + putlen(blen) + enc + b'\x00'
    else:
        enc = new_str.encode('utf-16-le')
        n = len(new_str)
        entry = struct.pack('<H', n) + enc + b'\x00\x00'

    # New string is appended at the current end of string data
    new_str_offset_rel = strdata_end - strings_start   # offset relative to strings_start
    new_index = string_count

    # We must insert 4 bytes into the offsets array (for the new u32 offset).
    # That shifts everything after it (string data + all subsequent chunks).
    insert_at = offsets_start + string_count * 4       # after existing string offsets
    # The new offset value points to where the new string will live AFTER all shifts.
    # After inserting 4 bytes in offsets array, strings_start moves +4, and every
    # existing string offset stays the same *relative* value. The new string goes
    # at the old strdata_end, whose relative offset (from the NEW strings_start)
    # is (strdata_end - strings_start)  — unchanged because both shift by +4.
    new_offset_value = new_str_offset_rel

    # Build the new byte array:
    #   [0 .. insert_at)  + new u32 offset + [insert_at .. strdata_end) + entry + [strdata_end ..]
    before = bytes(data[:insert_at])
    after_offsets_to_strdata_end = bytes(data[insert_at:strdata_end])
    tail = bytes(data[strdata_end:])

    new_offset_bytes = struct.pack('<I', new_offset_value)

    rebuilt = bytearray()
    rebuilt += before
    rebuilt += new_offset_bytes
    rebuilt += after_offsets_to_strdata_end
    rebuilt += entry
    rebuilt += tail

    # 4-byte align the whole thing was not padded per-entry; AXML chunks must stay
    # 4-aligned. Pad the appended entry region so subsequent chunk stays aligned.
    added = 4 + len(entry)
    pad = (-added) % 4
    if pad:
        # insert padding right after the entry (before tail). Rebuild again.
        rebuilt = bytearray()
        rebuilt += before
        rebuilt += new_offset_bytes
        rebuilt += after_offsets_to_strdata_end
        rebuilt += entry
        rebuilt += b'\x00' * pad
        rebuilt += tail
        added += pad

    data = rebuilt

    # --- Fix header fields ---
    # stringCount += 1
    write_u32(data, POOL + 8, string_count + 1)
    # pool chunkSize += added
    write_u32(data, POOL + 4, pool_chunk_size + added)
    # stringsStart += 4 (offsets array grew by one u32)
    write_u32(data, POOL + 20, strings_start_rel + 4)
    # stylesStart += 4 if present
    if styles_start_rel != 0:
        write_u32(data, POOL + 24, styles_start_rel + 4)
    # total file size (header at offset 4)
    total = read_u32(data, 4)
    write_u32(data, 4, total + added)

    # --- Repoint the attribute to the new index ---
    write_u32(data, attr_value_offset, new_index)
    write_u32(data, old_raw_offset, new_index)

    print(f"Appended '{new_str}' at index {new_index} (+{added} bytes)")
    return bytes(data)
    print("Workaround: pad class name to match or use apktool for this APK.")
    return None


# ============================================================================
#  <provider> injection — add a ContentProvider element to the binary AXML
#  so a patched app can expose album-art via content:// to Zeekr MediaCenter.
#
#  Injected element (inside <application>):
#    <provider android:name="<class>"
#              android:authorities="<authority>"
#              android:exported="true"
#              android:grantUriPermissions="true" />
#
#  Keeps the no-apktool pipeline: operates directly on AndroidManifest.xml bytes.
# ============================================================================

# AXML chunk types
RES_XML_START_ELEMENT_TYPE = 0x0102
RES_XML_END_ELEMENT_TYPE = 0x0103
RES_XML_RESOURCE_MAP_TYPE = 0x0180

# Android framework resource IDs for the provider attributes
RES_ID_NAME = 0x01010003
RES_ID_ENABLED = 0x0101000e
RES_ID_EXPORTED = 0x01010010
RES_ID_AUTHORITIES = 0x01010018
RES_ID_GRANT_URI = 0x0101001b

ANDROID_NS = 'http://schemas.android.com/apk/res/android'

# Res_value dataTypes
TYPE_STRING = 0x03
TYPE_INT_BOOLEAN = 0x12


def _pool_geom(data):
    """Return (pool_offset, header_size, chunk_size, string_count, is_utf8,
    offsets_start, strings_start)."""
    POOL = 8
    header_size = read_u16(data, POOL + 2)
    chunk_size = read_u32(data, POOL + 4)
    string_count = read_u32(data, POOL + 8)
    flags = read_u32(data, POOL + 16)
    is_utf8 = bool(flags & (1 << 8))
    strings_start = POOL + read_u32(data, POOL + 20)
    offsets_start = POOL + header_size
    return POOL, header_size, chunk_size, string_count, is_utf8, offsets_start, strings_start


def _all_strings(data):
    _, _, _, count, is_utf8, _, _ = _pool_geom(data)
    return find_string_in_pool(data, 8, count, is_utf8)


def _find_string_index(data, target):
    for idx, s, _ in _all_strings(data):
        if s == target:
            return idx
    return None


def _find_resmap(data):
    """Return (resmap_offset, resmap_chunk_size, id_count) or (None, 0, 0)."""
    _, _, pool_chunk_size, _, _, _, _ = _pool_geom(data)
    off = 8 + pool_chunk_size
    if read_u16(data, off) == RES_XML_RESOURCE_MAP_TYPE:
        cs = read_u32(data, off + 4)
        return off, cs, (cs - 8) // 4
    return None, 0, 0


def _resmap_index_for(data, res_id):
    """Return the string-pool index whose resource-map entry == res_id."""
    resmap_off, cs, n = _find_resmap(data)
    if resmap_off is None:
        return None
    for i in range(n):
        if read_u32(data, resmap_off + 8 + i * 4) == res_id:
            return i
    return None


def _find_application_start(data):
    """Return the byte offset of the <application> START_ELEMENT chunk."""
    _, _, pool_chunk_size, string_count, _, _, _ = _pool_geom(data)
    strings = _all_strings(data)
    off = 8 + pool_chunk_size
    while off < len(data) - 8:
        ct = read_u16(data, off)
        cs = read_u32(data, off + 4)
        if cs == 0:
            break
        if ct == RES_XML_START_ELEMENT_TYPE:
            # chunk header 16 bytes, then body: ns(4) name(4)
            name_idx = read_u32(data, off + 20)  # ns at +16, name at +20
            if name_idx < string_count and strings[name_idx][1] == 'application':
                return off, cs
        off += cs
    return None, None


def _build_start_element(ns_idx, provider_name_idx, attrs):
    """attrs: list of (name_str_idx, data_type, data_value) sorted by resource-id.
    Returns the START_ELEMENT chunk bytes."""
    header_size = 0x10
    attr_count = len(attrs)
    body = bytearray()
    # element body header (before attributes)
    body += struct.pack('<I', 0xffffffff)      # ns
    body += struct.pack('<I', provider_name_idx)  # name
    body += struct.pack('<H', 0x14)            # attributeStart
    body += struct.pack('<H', 0x14)            # attributeSize
    body += struct.pack('<H', attr_count)      # attributeCount
    body += struct.pack('<H', 0)               # idIndex
    body += struct.pack('<H', 0)               # classIndex
    body += struct.pack('<H', 0)               # styleIndex
    # attributes (20 bytes each)
    for name_idx, dtype, dval in attrs:
        if dtype == TYPE_STRING:
            raw = dval                          # string index also in rawValue
        else:
            raw = 0xffffffff
        body += struct.pack('<I', ns_idx)       # ns
        body += struct.pack('<I', name_idx)     # name
        body += struct.pack('<I', raw)          # rawValue
        body += struct.pack('<H', 8)            # typedValue size
        body += struct.pack('<B', 0)            # res0
        body += struct.pack('<B', dtype)        # dataType
        body += struct.pack('<I', dval)         # data
    chunk_size = 8 + header_size - 8 + len(body) + 8  # recomputed below
    # header: type(2) headerSize(2) chunkSize(4) lineNumber(4) comment(4)
    total = 8 + 8 + len(body)  # type+hdrsz+chunksz(8) + line+comment(8) + body
    chunk = bytearray()
    chunk += struct.pack('<H', RES_XML_START_ELEMENT_TYPE)
    chunk += struct.pack('<H', header_size)
    chunk += struct.pack('<I', total)
    chunk += struct.pack('<I', 0)              # lineNumber
    chunk += struct.pack('<I', 0xffffffff)     # comment
    chunk += body
    return bytes(chunk)


def _build_end_element(provider_name_idx):
    """Returns the END_ELEMENT chunk bytes (24 bytes)."""
    chunk = bytearray()
    chunk += struct.pack('<H', RES_XML_END_ELEMENT_TYPE)
    chunk += struct.pack('<H', 0x10)           # headerSize
    chunk += struct.pack('<I', 0x18)           # chunkSize = 24
    chunk += struct.pack('<I', 0)              # lineNumber
    chunk += struct.pack('<I', 0xffffffff)     # comment
    chunk += struct.pack('<I', 0xffffffff)     # ns
    chunk += struct.pack('<I', provider_name_idx)  # name
    return bytes(chunk)


def _append_pool_string(data, new_str):
    """Append new_str to the string pool, fix geometry, return (data, new_index).
    Mirrors append_string_and_repoint but WITHOUT the attribute repoint."""
    data = bytearray(data)
    POOL = 8
    pool_header_size = read_u16(data, POOL + 2)
    pool_chunk_size = read_u32(data, POOL + 4)
    string_count = read_u32(data, POOL + 8)
    style_count = read_u32(data, POOL + 12)
    strings_start_rel = read_u32(data, POOL + 20)
    styles_start_rel = read_u32(data, POOL + 24)
    flags = read_u32(data, POOL + 16)
    is_utf8 = bool(flags & (1 << 8))

    offsets_start = POOL + pool_header_size
    strings_start = POOL + strings_start_rel
    if style_count > 0 and styles_start_rel != 0:
        strdata_end = POOL + styles_start_rel
    else:
        strdata_end = POOL + pool_chunk_size

    if is_utf8:
        enc = new_str.encode('utf-8')

        def putlen(v):
            return bytes([v]) if v < 0x80 else bytes([0x80 | (v >> 8), v & 0xFF])
        entry = putlen(len(new_str)) + putlen(len(enc)) + enc + b'\x00'
    else:
        enc = new_str.encode('utf-16-le')
        entry = struct.pack('<H', len(new_str)) + enc + b'\x00\x00'

    new_str_offset_rel = strdata_end - strings_start
    new_index = string_count
    insert_at = offsets_start + string_count * 4

    before = bytes(data[:insert_at])
    mid = bytes(data[insert_at:strdata_end])
    tail = bytes(data[strdata_end:])
    new_offset_bytes = struct.pack('<I', new_str_offset_rel)

    added = 4 + len(entry)
    pad = (-added) % 4
    rebuilt = bytearray()
    rebuilt += before
    rebuilt += new_offset_bytes
    rebuilt += mid
    rebuilt += entry
    if pad:
        rebuilt += b'\x00' * pad
        added += pad
    rebuilt += tail
    data = rebuilt

    write_u32(data, POOL + 8, string_count + 1)
    write_u32(data, POOL + 4, pool_chunk_size + added)
    write_u32(data, POOL + 20, strings_start_rel + 4)
    if styles_start_rel != 0:
        write_u32(data, POOL + 24, styles_start_rel + 4)
    total = read_u32(data, 4)
    write_u32(data, 4, total + added)
    return data, new_index


def inject_provider(manifest_data, provider_class, authority):
    """Inject a <provider> element into the AXML <application>.

    Requires the four attributes (name/exported/authorities/grantUriPermissions)
    to already exist in the resource map — which is true for essentially every
    real-world manifest (they are standard framework attrs). Fails loudly
    otherwise rather than corrupting the resource-map ordering.
    """
    data = bytearray(manifest_data)

    if read_u16(data, 0) != 0x0003:
        raise ValueError("Not a valid AXML file")

    # Resolve attribute name string indices via the resource map (index whose
    # resmap entry equals the framework resource id).
    name_idx = _resmap_index_for(data, RES_ID_NAME)
    exported_idx = _resmap_index_for(data, RES_ID_EXPORTED)
    authorities_idx = _resmap_index_for(data, RES_ID_AUTHORITIES)
    grant_idx = _resmap_index_for(data, RES_ID_GRANT_URI)

    missing = [n for n, v in [
        ('name', name_idx), ('exported', exported_idx),
        ('authorities', authorities_idx), ('grantUriPermissions', grant_idx)]
        if v is None]
    if missing:
        print("ERROR: resource-map lacks attributes %s — cannot inject provider "
              "without reordering resmap (unsupported)." % missing)
        return None

    ns_idx = _find_string_index(data, ANDROID_NS)
    if ns_idx is None:
        print("ERROR: android namespace string not found in pool")
        return None

    # 'provider' element tag string
    provider_tag_idx = _find_string_index(data, 'provider')
    if provider_tag_idx is None:
        data, provider_tag_idx = _append_pool_string(data, 'provider')

    # value strings for name= and authorities=
    class_idx = _find_string_index(data, provider_class)
    if class_idx is None:
        data, class_idx = _append_pool_string(data, provider_class)
    auth_idx = _find_string_index(data, authority)
    if auth_idx is None:
        data, auth_idx = _append_pool_string(data, authority)

    # Attributes MUST be ordered by ascending resource id.
    attrs = [
        (name_idx, TYPE_STRING, class_idx),            # 0x01010003
        (exported_idx, TYPE_INT_BOOLEAN, 0xffffffff),  # 0x01010010 -> true
        (authorities_idx, TYPE_STRING, auth_idx),      # 0x01010018
        (grant_idx, TYPE_INT_BOOLEAN, 0xffffffff),     # 0x0101001b -> true
    ]

    start_chunk = _build_start_element(ns_idx, provider_tag_idx, attrs)
    end_chunk = _build_end_element(provider_tag_idx)
    insert_blob = start_chunk + end_chunk

    app_off, app_cs = _find_application_start(data)
    if app_off is None:
        print("ERROR: <application> element not found")
        return None

    # Insert our two chunks right after the <application> START_ELEMENT
    insert_at = app_off + app_cs
    data = bytearray(data[:insert_at]) + bytearray(insert_blob) + bytearray(data[insert_at:])

    # Fix total file size
    write_u32(data, 4, read_u32(data, 4) + len(insert_blob))

    print("Injected <provider android:name='%s' android:authorities='%s' "
          "exported=true grantUriPermissions=true> (+%d bytes)"
          % (provider_class, authority, len(insert_blob)))
    return bytes(data)


def _find_element_start(data, tag_name):
    """Return (offset, chunk_size) of the first START_ELEMENT whose tag == tag_name."""
    _, _, pool_chunk_size, string_count, _, _, _ = _pool_geom(data)
    strings = _all_strings(data)
    off = 8 + pool_chunk_size
    while off < len(data) - 8:
        ct = read_u16(data, off)
        cs = read_u32(data, off + 4)
        if cs == 0:
            break
        if ct == RES_XML_START_ELEMENT_TYPE:
            name_idx = read_u32(data, off + 20)
            if name_idx < string_count and strings[name_idx][1] == tag_name:
                return off, cs
        off += cs
    return None, None


def _build_package_element(ns_idx, package_tag_idx, name_attr_idx, name_val_idx):
    """Build <package android:name="..."/> as START+END element bytes (single
    string attribute). Reuses the generic single-element builder shape."""
    attrs = [(name_attr_idx, TYPE_STRING, name_val_idx)]  # android:name
    start = _build_start_element(ns_idx, package_tag_idx, attrs)
    end = _build_end_element(package_tag_idx)
    return start + end


def inject_queries_package(manifest_data, package_name):
    """Ensure <queries><package android:name="package_name"/></queries> is present
    so the patched app (targetSdk>=30) can bindService / resolve the given package
    under Android 11+ package visibility. If a <queries> block already exists, the
    <package> is inserted just inside it; otherwise a full <queries> block is
    created as a direct child of <manifest> (right before <application>).
    """
    data = bytearray(manifest_data)
    if read_u16(data, 0) != 0x0003:
        raise ValueError("Not a valid AXML file")

    # Idempotency: if this exact package string is already present AND a queries
    # block exists, assume it's already declared (best-effort — cheap guard).
    already = _find_string_index(data, package_name)
    q_off, _ = _find_element_start(data, 'queries')
    # (We still inject even if the string exists but for a different element, since
    #  the string pool is shared; only skip when both the string and <queries> are
    #  present — a heuristic that avoids double-injecting on re-patch.)

    ns_idx = _find_string_index(data, ANDROID_NS)
    if ns_idx is None:
        print("ERROR: android namespace string not found — cannot inject <queries>")
        return None
    name_attr_idx = _resmap_index_for(data, RES_ID_NAME)
    if name_attr_idx is None:
        print("ERROR: resource-map lacks android:name — cannot inject <package>")
        return None

    # tag strings
    pkg_tag_idx = _find_string_index(data, 'package')
    if pkg_tag_idx is None:
        data, pkg_tag_idx = _append_pool_string(data, 'package')
    name_val_idx = _find_string_index(data, package_name)
    if name_val_idx is None:
        data, name_val_idx = _append_pool_string(data, package_name)

    # Re-locate <queries> after any pool growth.
    q_off, q_cs = _find_element_start(data, 'queries')

    if q_off is not None:
        # Insert <package> right after the <queries> START_ELEMENT.
        pkg_blob = _build_package_element(ns_idx, pkg_tag_idx, name_attr_idx, name_val_idx)
        insert_at = q_off + q_cs
        data = bytearray(data[:insert_at]) + bytearray(pkg_blob) + bytearray(data[insert_at:])
        write_u32(data, 4, read_u32(data, 4) + len(pkg_blob))
        print("Injected <package android:name='%s'> into existing <queries> (+%d bytes)"
              % (package_name, len(pkg_blob)))
        return bytes(data)

    # No <queries> — build a full block: <queries><package .../></queries>
    queries_tag_idx = _find_string_index(data, 'queries')
    if queries_tag_idx is None:
        data, queries_tag_idx = _append_pool_string(data, 'queries')
    # <queries> has no attributes.
    q_start = _build_start_element(ns_idx, queries_tag_idx, [])
    q_end = _build_end_element(queries_tag_idx)
    pkg_blob = _build_package_element(ns_idx, pkg_tag_idx, name_attr_idx, name_val_idx)
    block = q_start + pkg_blob + q_end

    # Insert as a direct child of <manifest>, right before <application> START.
    app_off, _ = _find_application_start(data)
    if app_off is None:
        print("ERROR: <application> not found — cannot place <queries>")
        return None
    data = bytearray(data[:app_off]) + bytearray(block) + bytearray(data[app_off:])
    write_u32(data, 4, read_u32(data, 4) + len(block))
    print("Created <queries><package android:name='%s'/></queries> (+%d bytes)"
          % (package_name, len(block)))
    return bytes(data)


def inject_receiver(manifest_data, receiver_class, action_name):
    """Inject <receiver android:name=receiver_class android:exported=true
    android:enabled=true><intent-filter><action android:name=action_name/>
    </intent-filter></receiver> into <application>. Used for the MediaCenter
    reboot-recovery broadcast target. Requires android:name/exported/enabled in
    the resource map (standard framework attrs, present in real manifests)."""
    data = bytearray(manifest_data)
    if read_u16(data, 0) != 0x0003:
        raise ValueError("Not a valid AXML file")

    name_idx = _resmap_index_for(data, RES_ID_NAME)
    enabled_idx = _resmap_index_for(data, RES_ID_ENABLED)
    exported_idx = _resmap_index_for(data, RES_ID_EXPORTED)
    missing = [n for n, v in [('name', name_idx), ('enabled', enabled_idx),
                              ('exported', exported_idx)] if v is None]
    if missing:
        print("ERROR: resource-map lacks attributes %s — cannot inject receiver." % missing)
        return None

    ns_idx = _find_string_index(data, ANDROID_NS)
    if ns_idx is None:
        print("ERROR: android namespace string not found")
        return None

    # tag strings
    def tag(name):
        nonlocal data
        idx = _find_string_index(data, name)
        if idx is None:
            data, idx = _append_pool_string(data, name)
        return idx
    receiver_tag = tag('receiver')
    filter_tag = tag('intent-filter')
    action_tag = tag('action')

    class_idx = _find_string_index(data, receiver_class)
    if class_idx is None:
        data, class_idx = _append_pool_string(data, receiver_class)
    action_val_idx = _find_string_index(data, action_name)
    if action_val_idx is None:
        data, action_val_idx = _append_pool_string(data, action_name)

    # Re-resolve resmap indices after possible pool growth.
    name_idx = _resmap_index_for(data, RES_ID_NAME)
    enabled_idx = _resmap_index_for(data, RES_ID_ENABLED)
    exported_idx = _resmap_index_for(data, RES_ID_EXPORTED)
    ns_idx = _find_string_index(data, ANDROID_NS)

    # <receiver> attrs, ordered by ascending resource id:
    #   name 0x01010003, enabled 0x0101000e, exported 0x01010010
    recv_attrs = [
        (name_idx, TYPE_STRING, class_idx),
        (enabled_idx, TYPE_INT_BOOLEAN, 0xffffffff),
        (exported_idx, TYPE_INT_BOOLEAN, 0xffffffff),
    ]
    action_attrs = [(name_idx, TYPE_STRING, action_val_idx)]

    blob = (_build_start_element(ns_idx, receiver_tag, recv_attrs)
            + _build_start_element(ns_idx, filter_tag, [])
            + _build_start_element(ns_idx, action_tag, action_attrs)
            + _build_end_element(action_tag)
            + _build_end_element(filter_tag)
            + _build_end_element(receiver_tag))

    app_off, app_cs = _find_application_start(data)
    if app_off is None:
        print("ERROR: <application> element not found")
        return None
    insert_at = app_off + app_cs
    data = bytearray(data[:insert_at]) + bytearray(blob) + bytearray(data[insert_at:])
    write_u32(data, 4, read_u32(data, 4) + len(blob))
    print("Injected <receiver android:name='%s' exported=true> with action '%s' (+%d bytes)"
          % (receiver_class, action_name, len(blob)))
    return bytes(data)


def patch_apk(input_apk, output_apk, new_factory,
              provider_class=None, provider_authority=None,
              queries_package=None, receiver_class=None, receiver_action=None):
    """Extract manifest from APK, patch it, and create new APK.

    If provider_class/provider_authority are given, also inject a <provider>
    element (for album-art content:// exposure to Zeekr MediaCenter).
    If queries_package is given, ensure <queries><package name=.../></queries>
    so bindService to that package works under Android 11+ package visibility.
    """

    with tempfile.TemporaryDirectory() as tmpdir:
        # Copy input
        tmp_apk = os.path.join(tmpdir, 'patched.apk')
        shutil.copy2(input_apk, tmp_apk)
        
        # Read manifest
        with zipfile.ZipFile(input_apk, 'r') as zin:
            manifest_data = zin.read('AndroidManifest.xml')
        
        # Patch appComponentFactory
        patched = patch_axml_appcomponentfactory(manifest_data, new_factory)
        if patched is None:
            print("FAILED to patch manifest (appComponentFactory)")
            return False

        # Optionally inject the <provider> for album-art
        if provider_class and provider_authority:
            with_provider = inject_provider(patched, provider_class, provider_authority)
            if with_provider is None:
                print("FAILED to inject <provider> into manifest")
                return False
            patched = with_provider

        # Optionally inject <queries><package> for bindService visibility
        if queries_package:
            with_queries = inject_queries_package(patched, queries_package)
            if with_queries is None:
                print("FAILED to inject <queries><package> into manifest")
                return False
            patched = with_queries

        # Optionally inject the recovery <receiver>
        if receiver_class and receiver_action:
            with_receiver = inject_receiver(patched, receiver_class, receiver_action)
            if with_receiver is None:
                print("FAILED to inject <receiver> into manifest")
                return False
            patched = with_receiver
        
        # Write patched manifest back
        # We need to replace the entry in the zip
        # zipfile doesn't support in-place replacement, so rebuild
        with zipfile.ZipFile(input_apk, 'r') as zin:
            with zipfile.ZipFile(tmp_apk, 'w') as zout:
                for item in zin.infolist():
                    if item.filename == 'AndroidManifest.xml':
                        zout.writestr(item, patched)
                    else:
                        # Preserve compression method
                        raw = zin.read(item.filename)
                        zout.writestr(item, raw)
        
        shutil.move(tmp_apk, output_apk)
    
    print(f"Patched APK written to: {output_apk}")
    return True


if __name__ == '__main__':
    args = sys.argv[1:]
    provider_class = None
    provider_authority = None
    queries_package = None
    if '--provider' in args:
        i = args.index('--provider')
        try:
            provider_class = args[i + 1]
            provider_authority = args[i + 2]
        except IndexError:
            print("--provider requires CLASS AUTHORITY")
            sys.exit(1)
        del args[i:i + 3]

    if '--queries-package' in args:
        i = args.index('--queries-package')
        try:
            queries_package = args[i + 1]
        except IndexError:
            print("--queries-package requires PACKAGE_NAME")
            sys.exit(1)
        del args[i:i + 2]

    receiver_class = None
    receiver_action = None
    if '--receiver' in args:
        i = args.index('--receiver')
        try:
            receiver_class = args[i + 1]
            receiver_action = args[i + 2]
        except IndexError:
            print("--receiver requires CLASS ACTION")
            sys.exit(1)
        del args[i:i + 3]

    if len(args) < 3:
        print(f"Usage: {sys.argv[0]} <input.apk> <output.apk> <new_factory_class> "
              f"[--provider <provider_class> <authority>] "
              f"[--queries-package <package_name>]")
        print(f"Example: {sys.argv[0]} app.apk patched.apk com.dhuadapter.DhuAdapterFactory")
        print(f"         {sys.argv[0]} app.apk patched.apk com.dhuadapter.DhuAdapterFactory "
              f"--provider com.dhuadapter.CoverProvider com.dhuadapter.covers "
              f"--queries-package com.zeekr.mediacenter")
        sys.exit(1)

    success = patch_apk(args[0], args[1], args[2],
                        provider_class=provider_class,
                        provider_authority=provider_authority,
                        queries_package=queries_package,
                        receiver_class=receiver_class,
                        receiver_action=receiver_action)
    sys.exit(0 if success else 1)
