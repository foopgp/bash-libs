<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-QIF
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-qif - manual page for bl-qif 0.1.8

# SYNOPSIS

**bl-qif** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# OPTIONS

**-h**, **\--help**

:   show help and exit/return

**-V**, **\--version**

:   show version and exit/return

## Actions:

qif_tobash

:   Convert each qif entry to a \"declare **-A** \...\" statement to be
    loaded with eval.

qif_tojournal

:   Reorganize qif entries to maintain coherent monthly journal

qif_stat

:   Extract stats from Given .qif files

qif_tofecp4

:   Parse qif file, and ask some questions for each entries to manage
    foopgp tockens, expenses, inventory\....

 
All actions support a **\--help** options, eg: \$ bl-qif ACTION
**\--help**

bl-qif is also bash library, see: \$ source bl-qif **\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

