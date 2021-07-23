---
title: BL-INTERACTIVE
section: 1
header: User Commands
footer: bash-libs
date: July 2021
---

# NAME

bl-interactive - Help managing interactive choices

# SYNOPSIS

**bl-interactive** [*OPTIONS*]... *ACTION* [*ACTION_ARGUMENTS*]...

# DESCRIPTION

This executable/library exposes 2 functions: **bl_yesno()** and
**bl_chooseinlist()**.

# GENERAL OPTIONS

**-h**, **--help**
:  print help and exit/return

**-V**, **--version**
:  show version and exit/return

# ACTIONS / FUNCTIONS

**yesno** / **bl_yesno()**
:  Helper for a yes/no question (binary choice)

**chooseinlist** / **bl_chooseinlist()**
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

