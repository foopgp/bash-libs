<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-SECURITY
section: 1
header: User Commands
footer: bash-libs 0.2.6
---

# NAME

bl-security - Provide some cybersecurity features.

# SYNOPSIS

**bl-security** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Provide some cybersecurity features.

## Main options:

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog,zenity} (environment
    var: BL_INTERACTIVE_FRONTEND)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

urandom

:   Output a good random number between 0 and 1\<\<32 (4294967296).

shred_path

:   Recursively shred all files in given path(\|s).

gen_passphrase

:   Generate a good random passphrase.

new_password

:   Ask to enter a new password and force retyping it.

shrink_num

:   Shrink input data to a number limited by SIZE.

 
All actions support a **\--help** option, eg: \$ bl-security
urandom **\--help**

bl-security is also bash library, see: \$ source bl-security
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

