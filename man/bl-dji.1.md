<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-DJI
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-dji - manual page for bl-dji 0.1.2

# SYNOPSIS

**bl-dji** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Manage djis (Ɉ), also known as foopgp tokens.

# OPTIONS

**-h**, **\--help**

:   show this help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

2micro

:   Translate given VALUES to their microVALUES, aka µVALUES (10\^-6).

2deci

:   Translate given VALUES to their deciVALUES, aka dVALUES (10\^-1).

2milli

:   Translate given VALUES to their milliVALUES, aka mVALUES (10\^-3).

2bin

:   Translate given VALUES to their µVALUES: round(VALUE\*10\^6), then
    to binary.

2powersoftwo

:   Translate given VALUES v to their microVALUES µv (10\^-6), then
    decompose this (µv) in powers of 2.

readwallet

:   Read dji wallet FILE(s), or from */dev/stdin* if no FILE passed as
    argument.

stripwallet

:   Select and output grains from wallet FILE to be removed to extract
    VALUE.

 
All actions support a **\--help** options, eg: \$ bl-dji ACTION
**\--help**

bl-dji is also bash library, see: \$ source bl-dji **\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

