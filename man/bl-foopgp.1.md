<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-FOOPGP
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-foopgp - manual page for bl-foopgp 0.0.5

# SYNOPSIS

**bl-foopgp** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Calculate how many foopgp token (Ɉ) may be created for each cotisations
to the the foopgp association.

# OPTIONS

**-h**, **\--help**

:   show this help and exit/return

**-V**, **\--version**

:   show version and exit/return

**-s**, **\--stingynalty** VALUE

:   set STINGYNALTY (current: 1.08307115127602379972)

**-d**, **\--date** STRING

:   set STINGYNALTY according to given date (cf.
    \<https://www.gnu.org/software/coreutils/date\>)

## Actions:

foopgp_g2t

:   Calculate how many foopgp tokens would be created from a gift.

foopgp_t2g

:   Calculate how much should be given to create a targeted number of
    tokens.

foopgp_giftarray

:   Display an array to indicate how many token gonna be created from a
    gift.

 
All actions support a **\--help** options, eg: \$ bl-foopgp
ACTION **\--help**

bl-foopgp is also bash library, see: \$ source bl-foopgp
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

