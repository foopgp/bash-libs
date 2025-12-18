<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-QIF
section: 1
header: User Commands
footer: bash-libs 0.1.10
---

# NAME

bl-qif - Main options:

# SYNOPSIS

**bl-qif** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

## Main options:

**-h**, **\--help**

:   show help and exit/return

**-V**, **\--version**

:   show version and exit/return

## Actions:

tobash

:   Convert each qif entry to a \"declare **-A** \...\" statement to be
    loaded with eval.

tojournal

:   Reorganize qif entries to maintain coherent monthly journal

stat

:   Extract stats from Given .qif files

tofecp4

:   Parse qif file, and ask some questions for each entries to manage
    foopgp tokens, expenses, inventory\....

 
All actions support a **\--help** options, eg: \$ bl-qif tobash
**\--help**

bl-qif is also bash library, see: \$ source bl-qif **\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

