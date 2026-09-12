#!/usr/bin/env python3
"""
extract_apk_cert.py <input.apk> <out.der>

Extract the first signer's first X.509 certificate (raw DER) from an APK's
v2/v3 APK Signing Block. Modern APKs (e.g. Spotify) ship NO v1 (.RSA) block, so
the genuine cert lives only in the signing block. Used by patch_apk.sh
--copy-sign to preserve the stock cert as assets/orig-cert.der before re-signing.

Exit 0 + writes out.der on success; exit 1 with a message otherwise.
"""
import struct
import sys

APK_SIG_BLOCK_MAGIC = b"APK Sig Block 42"
V2_ID = 0x7109871A
V3_ID = 0xF05368C0
V31_ID = 0x1B93AD61  # v3.1


def find_eocd_cd_offset(data: bytes) -> int:
    """Return the Central Directory start offset from the EOCD record."""
    sig = b"\x50\x4b\x05\x06"  # EOCD signature
    max_back = min(len(data), 65535 + 22)
    window = data[len(data) - max_back:]
    idx = window.rfind(sig)
    if idx < 0:
        raise ValueError("EOCD not found (not a zip/apk?)")
    eocd = len(data) - max_back + idx
    (cd_offset,) = struct.unpack_from("<I", data, eocd + 16)  # CD offset uint32 LE
    if cd_offset == 0xFFFFFFFF:
        # ZIP64: the real CD offset lives in the ZIP64 EOCD record, not here.
        raise ValueError("ZIP64 APK — CD offset in ZIP64 EOCD not supported")
    return cd_offset


def find_signing_block(data: bytes, cd_offset: int) -> bytes:
    """Return the ID-value pairs region of the APK Signing Block."""
    if cd_offset < 32:
        raise ValueError("CD offset too small for a signing block")
    magic = data[cd_offset - 16:cd_offset]
    if magic != APK_SIG_BLOCK_MAGIC:
        raise ValueError("APK Signing Block magic not found (v1-only / unsigned?)")
    (blk_size,) = struct.unpack_from("<Q", data, cd_offset - 24)
    block_start = cd_offset - 8 - blk_size
    if block_start < 0:
        raise ValueError("Bad signing block size")
    (blk_size2,) = struct.unpack_from("<Q", data, block_start)
    if blk_size2 != blk_size:
        raise ValueError("Signing block size mismatch")
    return data[block_start + 8: cd_offset - 24]


def iter_pairs(pairs: bytes):
    off, n = 0, len(pairs)
    while off + 12 <= n:
        (length,) = struct.unpack_from("<Q", pairs, off)  # uint64: id(4)+value
        off += 8
        if length < 4 or off + length > n:
            break
        (pid,) = struct.unpack_from("<I", pairs, off)
        yield pid, pairs[off + 4: off + length]
        off += length


def _u32_seq(buf: bytes):
    """Yield length-prefixed (uint32 LE) elements of a sequence."""
    off, n = 0, len(buf)
    while off + 4 <= n:
        (ln,) = struct.unpack_from("<I", buf, off)
        off += 4
        if off + ln > n:
            break
        yield buf[off: off + ln]
        off += ln


def first_cert_from_block(value: bytes) -> bytes:
    """value = a v2/v3 block: [uint32 signers-seq-len][signer...]. Each signer =
    [signed_data][signatures][public_key]; signed_data = [digests][certificates]
    [...]. Return the first signer's first certificate DER."""
    if len(value) < 4:
        raise ValueError("empty block")
    (seq_len,) = struct.unpack_from("<I", value, 0)
    signers_seq = value[4:4 + seq_len]
    for signer in _u32_seq(signers_seq):
        parts = list(_u32_seq(signer))        # [signed_data, signatures, public_key]
        if not parts:
            continue
        sd = list(_u32_seq(parts[0]))         # [digests, certificates, ...]
        if len(sd) < 2:
            continue
        certs = list(_u32_seq(sd[1]))
        if certs:
            return certs[0]
    raise ValueError("no certificate found in signer block")


def main():
    if len(sys.argv) != 3:
        print("usage: extract_apk_cert.py <input.apk> <out.der>", file=sys.stderr)
        return 2
    apk, out = sys.argv[1], sys.argv[2]
    with open(apk, "rb") as f:
        data = f.read()
    cd = find_eocd_cd_offset(data)
    pairs = find_signing_block(data, cd)
    blocks = dict(iter_pairs(pairs))
    for pid in (V31_ID, V3_ID, V2_ID):
        if pid in blocks:
            try:
                der = first_cert_from_block(blocks[pid])
            except Exception:
                continue
            with open(out, "wb") as w:
                w.write(der)
            print("extracted signer cert (%d bytes) from block 0x%08x" % (len(der), pid))
            return 0
    print("no v2/v3 signer certificate found", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
