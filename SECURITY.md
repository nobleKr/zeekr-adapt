# Security Policy

## Scope

zeekr-adapt is an in-process runtime adapter for the Zeekr DHU. It works purely
through **public Android framework hooks** (Pine): it does **not** root the
device, does **not** use Xposed, and does **not** modify the target
application's code, resources, or embedded permissions. Everything it changes is
derived from live device metrics and framework state.

## What users should understand

- **You build and sign the adapter yourself.** Each user generates their own
  signing key; no pre-built signed binaries are distributed here. Do not install
  patched APKs from untrusted third parties.
- **Patched apps are re-signed with your key.** They are no longer signed by the
  original vendor, so they will not receive store updates and cannot be installed
  side-by-side with the store version.
- **Use at your own risk.** Patching and running modified apps may violate the
  terms of service of those apps. This project is for personal, non-commercial
  use on your own hardware.

## Reporting a vulnerability

If you find a security issue in this repository's code (the adapter, build
scripts, or manifest patcher), please report it privately:

- Use **GitHub's private vulnerability reporting** (repository **Security** tab
  → **"Report a vulnerability"**), or
- Open a minimal issue **without** exploit details and ask for a private channel.

Please do **not** file public issues that include working exploit steps. We aim
to acknowledge reports within a reasonable time and address confirmed issues in
a subsequent release.

## Out of scope

- **Server-side behaviour of third-party apps** (integrity / anti-tamper checks,
  account flagging) — that is controlled by those apps' vendors, not by this
  project.
- **The security of APKs you obtain elsewhere.** Only patch apps you have
  legally obtained.
