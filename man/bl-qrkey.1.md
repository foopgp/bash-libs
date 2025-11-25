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

bl-qrkey - manual page for bl-qrkey 0.1.5

# SYNOPSIS

**bl-qrkey** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Backup or restore OpenPGP keys using printed QR codes.

# OPTIONS

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog} (environment var:
    BL_INTERACTIVE_FRONTEND)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

print

:   Export and print secret keys on multiple QRcode using Shamir\'s
    secret sharing.

scan

:   Reconstitute OpenPGP secrets from QRcodes scanned from IMAGES or
    webcam.

 
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

