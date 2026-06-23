<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-TEST
section: 1
header: User Commands
footer: bash-libs 0.2.5
---

# NAME

bl-test - Main options:

# SYNOPSIS

**bl-test** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

## Main options:

**-h**, **\--help**

:   show help and exit/return

**-V**, **\--version**

:   show version and exit/return

## Actions:

test\_\_version

:   Test if \"COMMANDE \[ARG\]\... **\--version**\" matches GNU
    standard.

 
All actions support a **\--help** options, eg: \$ bl-test ACTION
**\--help**

bl-test is also bash library, see: \$ source bl-test **\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

