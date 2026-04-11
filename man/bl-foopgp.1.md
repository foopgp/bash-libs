<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-FOOPGP
section: 1
header: User Commands
footer: bash-libs 0.3.5
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

:   set STINGYNALTY (2026-04: 1.11597215534802776295)

**-d**, **\--date** STRING

:   set STINGYNALTY according to given date (cf.
    \<https://www.gnu.org/software/coreutils/date\>)

**-h**, **\--help**

:   Show help and exit.

**-V**, **\--version**

:   Show version and exit.

## ACTIONS:

g2t

:   Calculate how many djis (Ɉ) would be created from a contribution in
    euros (€).

t2g

:   Calculate how much euros (€) should be given to create a targeted
    number of djis (Ɉ).

giftarray

:   Display an array to indicate how many djis (Ɉ) gonna be created from
    a contribution in euros (€).

update_input

:   Update EUR-input.log in the dji directory tree.

update_contribs

:   Update \'contributions.md\' according to new entries in
    \'EUR-input.log\'.

symlinks

:   Update symlinks in the foopgp tree.

contribs

:   Calculate total contributions and total djis (Ɉ) created by
    contributions.

 
All actions support a **\--help** option, eg: \$ bl-foopgp g2t
**\--help**

bl-foopgp is also bash library, see: \$ source bl-foopgp
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

