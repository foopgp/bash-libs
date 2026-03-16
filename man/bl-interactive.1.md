<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-INTERACTIVE
section: 1
header: User Commands
footer: bash-libs 0.3.3
---

# NAME

bl-interactive - Help managing interactive choices, while supporting
multiple frontends: NONE, whiptail, dialog or zenity.

# SYNOPSIS

**bl-interactive** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Help managing interactive choices, while supporting multiple frontends:
NONE, whiptail, dialog or zenity.

## MAIN OPTIONS:

**-f**, **\--frontend** PROGRAM

:   Select a frontend program {NONE,whiptail,dialog,zenity} -
    Environment variable: BL_INTERACTIVE_FRONTEND, default: NONE

**-z**, **\--zenity-extra** ARGS

:   Extra args for zenity (if used) (zenity **\--help-general**) -
    Environment variable: BL_INTERACTIVE_ZENITY_EXTRA, default:

**-h**, **\--help**

:   Show help and exit.

**-V**, **\--version**

:   Show version and exit.

## ACTIONS:

msgstop

:   Display a MESSAGE and wait for user to press \[Enter\].

input

:   Helper to ask for a string.

yesno

:   Helper for a yes/no QUESTION (binary choice).

radiolist

:   Helper for a single choice in a list (like radiobutton).

 
All actions support a **\--help** option, eg: \$ bl-interactive
msgstop **\--help**

bl-interactive is also bash library, see: \$ source
../bin/bl-interactive **\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

