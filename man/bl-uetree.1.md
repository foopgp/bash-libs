<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-UETREE
section: 1
header: User Commands
footer: bash-libs 0.3.15
---

# NAME

bl-uetree - Manage a uetree, a filesystem-native registry of
self-certifying entities.

# SYNOPSIS

**bl-uetree** \[*MAIN_OPTIONS*\]\... *ACTION *\[*ARGS*\]\...

# DESCRIPTION

Manage a uetree, a filesystem-native registry of self-certifying
entities. Each entity is keyed by an OpenPGP identifier and
cross-indexed by email, phone and name ; its canonical record is a vCard
4.0 file (entity.vcf).

## MAIN OPTIONS:

**-h**, **\--help**

:   Show this help and exit

**-V**, **\--version**

:   Show version and exit

## ACTIONS:

check

:   Validate a uetree instance rooted at PATH (default: current
    directory).

resolve

:   Resolve ITEM (an eid, e-mail, phone or name) to its canonical entity
    leaf(s).

leaves

:   List a uetree\'s canonical entity leaves (those holding entity.vcf).

aliases

:   Regenerate or verify a uetree\'s .ALIASES membership manifests.

promote

:   Promote a by-email/ leaf to its certified canonical by-eid/
    position.

 
All actions support a **\--help** option, eg: \$ bl-uetree check
**\--help**

bl-uetree is also a bash library, see: \$ source bl-uetree
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

