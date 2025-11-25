<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-DJIBIAN
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-djibian - manual page for bl-djibian 0.1.5

# SYNOPSIS

**bl-djibian** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

System tools for Djibian GNU/Linux.

# OPTIONS

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog} (environment var:
    BL_INTERACTIVE_FRONTEND)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

adduser

:   Add user to this djibian system. Need root permissions (sudo).
    Missing input will be asked interactively.

admins

:   List, add or remove local admins (root power through sudo group).
    Add or remove need admin rights.

 
All actions support a **\--help** options, eg: \$ bl-djibian
ACTION **\--help**

bl-djibian is also bash library, see: \$ source bl-djibian
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

