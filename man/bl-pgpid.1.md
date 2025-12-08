<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-PGPID
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-pgpid - manual page for bl-pgpid 0.1.8

# SYNOPSIS

**bl-pgpid** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Generate foopgp identifiers, like \*udid4\* to identify world-wide
humans, or a fixed Unix User ID for each of them.

# OPTIONS

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog} (environment var:
    BL_INTERACTIVE_FRONTEND)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

mrz_to_u4

:   Convert the Machine Readable Zone of an icao9303 passport to an
    udid4 (aka \'u4\')

gen_u4

:   Generate udid4. Missing inputs are asked interactively.

2num

:   Shrink input data to a number limited by SIZE.

gen_uid

:   Generate a 32bit Unix User ID, from 2\^18 to (2\^31)-2
    (\[262144,2147483646\]).

gen_key

:   Generate an OpenPGP key pair (public and secret) according to foopgp
    standards.

tocken_check

:   Check if OpenPGP tocken is correctly configured for pgpid ; may
    output informations.

 
All actions support a **\--help** options, eg: \$ bl-pgpid ACTION
**\--help**

bl-pgpid is also bash library, see: \$ source bl-pgpid
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

