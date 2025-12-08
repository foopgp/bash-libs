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

bl-interactive - manual page for bl-interactive 0.1.8

# SYNOPSIS

**bl-interactive** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Help managing interactive choices, while supporting multiple frontends:
NONE, whiptail or dialog.

# OPTIONS

**-f**, **\--frontend** PROGRAM

:   select a frontend program {NONE,whiptail,dialog} (environment var:
    BL_INTERACTIVE_FRONTEND, default: NONE)

**-h**, **\--help**

:   show help and exit

**-V**, **\--version**

:   show version and exit

## Actions:

msgstop

:   Display a message and wait for user to press \[Enter\]

input

:   Helper to ask for a string

yesno

:   Helper for a yes/no question (binary choice)

radiolist

:   Helper for a single choice in a list (like radiobutton)

 
All actions support a **\--help** options, eg: \$ bl-interactive
ACTION **\--help**

bl-interactive is also bash library, see: \$ source
../bin/bl-interactive **\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

