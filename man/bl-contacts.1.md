<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-CONTACTS
section: 1
header: User Commands
footer: bash-libs 0.4.0
---

# NAME

bl-contacts - Create, check, fix and edit vCard 4.0 contact records (RFC
6350), filed inside a uetree.

# SYNOPSIS

**bl-contacts** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Create, check, fix and edit vCard 4.0 contact records (RFC 6350), filed
inside a uetree.

## MAIN OPTIONS:

**-f**, **\--frontend** PROGRAM

:   Select a frontend program {NONE,whiptail,dialog,zenity} -
    Environment variable: BL_INTERACTIVE_FRONTEND

**-h**, **\--help**

:   Show help and exit.

**-V**, **\--version**

:   Show version and exit.

## ACTIONS:

new

:   Create a new vCard 4.0 contact record inside a uetree, filed under
    by-name/.

check

:   Check vCard contact record(s), read from VCARD file or standard
    input.

checknfix

:   Repair common defects of vCard record(s) and output the result, best
    effort.

properties

:   Display, add or remove properties of vCard record(s).

 
All actions support a **\--help** option, eg: \$ bl-contacts new
**\--help**

bl-contacts is also bash library, see: \$ source bl-contacts
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

