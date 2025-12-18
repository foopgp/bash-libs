<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-QRKEY
section: 1
header: User Commands
footer: bash-libs 0.1.10
---

# NAME

bl-qrkey - Backup or restore OpenPGP keys using printed QR codes and
Shamir\'s secret sharing.

# SYNOPSIS

**bl-qrkey** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Backup or restore OpenPGP keys using printed QR codes and Shamir\'s
secret sharing. Also facilitate changing passphrase protecting OpenPGP
keys, or (PIN or Admin) codes of OpenPGP security tokens (YubiKey,
\...).

## Main options:

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog} (environment var:
    BL_INTERACTIVE_FRONTEND)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

change_passphrase

:   Change GnuPG passphrase protecting secret parts of an OpenPGP key.

change_token_code

:   Check and change PIN (or Admin) code protecting use of a security
    token (OpenPGP smartcard).

print

:   Export and print OpenPGP secrets on multiple QRcode using Shamir\'s
    secret sharing.

scan

:   Reconstitute OpenPGP secrets from QRcodes scanned from IMAGES or
    webcam.

totoken

:   Move OpenPGP secrets to security token (OpenPGP smartcard).

 
All actions support a **\--help** options, eg: \$ bl-qrkey
change_passphrase **\--help**

bl-qrkey is also bash library, see: \$ source bl-qrkey
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

