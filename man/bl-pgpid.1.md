<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-PGPID
section: 1
header: User Commands
footer: bash-libs 0.1.10
---

# NAME

bl-pgpid - Generate and manage (foo)pgp id : u4 identifiers (for
world-wide humans), fixed system \*uid\*, OpenPGP certificate, etc.

# SYNOPSIS

**bl-pgpid** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Generate and manage (foo)pgp id : u4 identifiers (for world-wide
humans), fixed system \*uid\*, OpenPGP certificate, etc.

## Main options:

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog} (environment var:
    BL_INTERACTIVE_FRONTEND)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

mrz_to_u4

:   Convert the Machine Readable Zone of an icao9303 passport to its u4
    identifier.

gen_u4

:   Generate u4 identifier. Missing inputs are asked interactively.

gen_uid

:   Generate a 32bit Unix User ID, from 2\^18 to (2\^31)-2
    (\[262144,2147483646\]).

gen_key

:   Generate an OpenPGP key pair (public and secret) according to foopgp
    standards.

avatar

:   Extract and/or add image from/to OpenPGP certificate.

email

:   Display and add or revoke emails inside OpenPGP certificate.

token_check

:   Check if OpenPGP token is correctly configured for pgpid ; may
    output informations.

 
All actions support a **\--help** options, eg: \$ bl-pgpid
mrz_to_u4 **\--help**

bl-pgpid is also bash library, see: \$ source bl-pgpid
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

