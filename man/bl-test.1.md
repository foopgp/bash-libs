<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-TEST
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-test - manual page for bl-test 0.1.3

# SYNOPSIS

**bl-test** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# OPTIONS

**-h**, **\--help**

:   show this help and exit/return

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

