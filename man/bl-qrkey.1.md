<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-QRKEY
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-qrkey - manual page for bl-qrkey 0.1.7

# SYNOPSIS

**bl-qrkey** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Backup or restore OpenPGP keys using printed QR codes and Shamir\'s
secret sharing.

# OPTIONS

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

print

:   Export and print OpenPGP secrets on multiple QRcode using Shamir\'s
    secret sharing.

scan

:   Reconstitute OpenPGP secrets from QRcodes scanned from IMAGES or
    webcam.

totoken

:   Move OpenPGP secrets to security token (OpenPGP smartcard).

 
All actions support a **\--help** options, eg: \$ bl-qrkey ACTION
**\--help**

bl-qrkey is also bash library, see: \$ source bl-qrkey
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

