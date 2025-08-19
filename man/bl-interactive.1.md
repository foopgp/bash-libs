<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-INTERACTIVE
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-interactive - Help managing interactive choices, while supporting multiple frontends: NONE, whiptail or dialog.

# SYNOPSIS

**bl-interactive** [*OPTIONS*]... *ACTION* [*ACTION_ARGUMENTS*]...

# DESCRIPTION

This executable/library exposes 2 functions: **bl_yesno()** and
**bl_radiolist()**.

# GENERAL OPTIONS

**-h**, **--help**
:  print help and exit/return

**-V**, **--version**
:  show version and exit/return

# ACTIONS / FUNCTIONS

**yesno** / **bl_yesno()**
:  Helper for a yes/no question (binary choice)

**radiolist** / **bl_radiolist()**
:  Helper for a single choice in a list (like radiobutton)

# SPECIFIC OPTIONS

# ENVIRONMENT VARIABLES

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# EXAMPLES


# SEE ALSO

[**bash-libs**](../README.md)(7).


# AUTHOR

Jean-Jacques Brucker

