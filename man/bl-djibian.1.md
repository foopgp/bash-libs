<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-DJIBIAN
section: 1
header: User Commands
footer: bash-libs 0.3.3
---

# NAME

bl-djibian - System tools for Djibian GNU/Linux. Mainly to manage users.

# SYNOPSIS

**bl-djibian** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

System tools for Djibian GNU/Linux. Mainly to manage users.

## MAIN OPTIONS:

**-f**, **\--frontend** PROGRAM

:   Select a frontend program {NONE,whiptail,dialog,zenity} -
    Environment variable: BL_INTERACTIVE_FRONTEND

**-h**, **\--help**

:   Show help and exit.

**-V**, **\--version**

:   Show version and exit.

## ACTIONS:

adduser

:   Add user to this djibian system. Need root permissions (sudo).

confhome4pgp

:   Reconfigure HOME directory for djibian\'s OpenPGP usage:

admins

:   List, add or remove local admins (root power through sudo group).
    Add or remove need admin rights.

 
All actions support a **\--help** option, eg: \$ bl-djibian
adduser **\--help**

bl-djibian is also bash library, see: \$ source bl-djibian
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

