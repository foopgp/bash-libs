<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-UETREE
section: 1
header: User Commands
footer: bash-libs 0.4.1
---

# NAME

bl-uetree - Manage a \'universal entities tree\', a filesystem-native
registry of well-defined, certified contacts.

# SYNOPSIS

**bl-uetree** \[*MAIN_OPTIONS*\]\... *ACTION *\[*ARGS*\]\...

# DESCRIPTION

Manage a \'universal entities tree\', a filesystem-native registry of
well-defined, certified contacts. Its storage architecture combines the
strengths of eids, git, vCard and the OpenPGP web of trust. Each entity
is cross-indexed by email, phone, name, eid, ...

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

