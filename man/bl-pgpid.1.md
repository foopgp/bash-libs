<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-PGPID
section: 1
header: User Commands
footer: bash-libs 0.2.7
---

# NAME

bl-pgpid - Generate and manage OpenPGP ID: u4 or u5 strings, fixed
system \*uid\*, OpenPGP certificate, etc.

# SYNOPSIS

**bl-pgpid** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Generate and manage OpenPGP ID: u4 or u5 strings, fixed system \*uid\*,
OpenPGP certificate, etc.

## Main options:

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog,zenity} (environment
    var: BL_INTERACTIVE_FRONTEND)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

mrz_to_u4

:   Calculate and output a OpenPGP ID u4, from the Machine Readable Zone
    of an icao9303 passport.

gen_u4

:   Generate OpenPGP ID u4 string. Missing input will be asked
    interactively.

gen_uid

:   Generate a 32bit Unix User ID, from 2\^18 to (2\^31)-2
    (\[262144,2147483646\]).

gen_key

:   Generate an OpenPGP key pair (public and secret) according to
    OpenPGP ID standards.

avatar

:   Extract or add image inside OpenPGP certificate.

email

:   Display and add or revoke emails inside OpenPGP certificate.

token_check

:   Check if OpenPGP token is correctly configured for OpenPGP ID ; may
    output informations.

certify

:   Certify somebody else, identified by its OpenPGP ID TARGET_U4.

 
All actions support a **\--help** option, eg: \$ bl-pgpid
mrz_to_u4 **\--help**

bl-pgpid is also bash library, see: \$ source bl-pgpid
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

