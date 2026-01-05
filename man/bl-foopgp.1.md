<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-FOOPGP
section: 1
header: User Commands
footer: bash-libs 0.2.1
---

# NAME

bl-foopgp - Calculate how many foopgp token (Ɉ) may be created for each
cotisations to the the foopgp association.

# SYNOPSIS

**bl-foopgp** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Calculate how many foopgp token (Ɉ) may be created for each cotisations
to the the foopgp association.

## Main options:

**-v**, **\--verbose**

:   output important infos on stderr, like stingynalty value

**-s**, **\--stingynalty** VALUE

:   set STINGYNALTY (2026-01: 1.09939858426540376799)

**-d**, **\--date** STRING

:   set STINGYNALTY according to given date (cf.
    \<https://www.gnu.org/software/coreutils/date\>)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

g2t

:   Calculate how many foopgp tokens would be created from a gift.

t2g

:   Calculate how much should be given to create a targeted number of
    tokens.

giftarray

:   Display an array to indicate how many token gonna be created from a
    gift.

 
All actions support a **\--help** options, eg: \$ bl-foopgp g2t
**\--help**

bl-foopgp is also bash library, see: \$ source bl-foopgp
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

