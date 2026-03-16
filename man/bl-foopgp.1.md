<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-FOOPGP
section: 1
header: User Commands
footer: bash-libs 0.3.2
---

# NAME

bl-foopgp - Calculate how many djis (Ɉ) may be created for each
contribution in euros (€) to the the foopgp association.

# SYNOPSIS

**bl-foopgp** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Calculate how many djis (Ɉ) may be created for each contribution in
euros (€) to the the foopgp association.

## MAIN OPTIONS:

**-v**, **\--verbose**

:   output important infos on stderr, like stingynalty value

**-s**, **\--stingynalty** VALUE

:   set STINGYNALTY (2026-03: 1.11042005507266444075)

**-d**, **\--date** STRING

:   set STINGYNALTY according to given date (cf.
    \<https://www.gnu.org/software/coreutils/date\>)

**-h**, **\--help**

:   Show help and exit.

**-V**, **\--version**

:   Show version and exit.

## ACTIONS:

symlinks

:   Update symlinks in the foopgp tree.

g2t

:   Calculate how many djis (Ɉ) would be created from a contribution in
    euros (€).

t2g

:   Calculate how much euros (€) should be given to create a targeted
    number of djis (Ɉ).

giftarray

:   Display an array to indicate how many djis (Ɉ) gonna be created from
    a contribution in euros (€).

 
All actions support a **\--help** option, eg: \$ bl-foopgp
symlinks **\--help**

bl-foopgp is also bash library, see: \$ source bl-foopgp
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

