<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-SECURITY
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-security - manual page for bl-security 0.0.4

# SYNOPSIS

**bl-security** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Provide some security features.

# OPTIONS

**-h**, **\--help**

:   show this help and exit/return

**-V**, **\--version**

:   show version and exit/return

## Actions:

urandom

:   Output a good random number between 0 and 1\<\<32 (4294967296)

shred_path

:   Recursively shred all files in given path(\|s).

gen_passphrase

:   Generate a good random passphrase

 
All actions support a **\--help** options, eg: \$ bl-security
ACTION **\--help**

bl-security is also bash library, see: \$ source bl-security
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

