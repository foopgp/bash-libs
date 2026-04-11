<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-JSON
section: 1
header: User Commands
footer: bash-libs 0.3.5
---

# NAME

bl-json - Use jq (Command-line JSON processor) to convert json data to
bash variables or arrays, and vice-versa.

# SYNOPSIS

**bl-json** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Use jq (Command-line JSON processor) to convert json data to bash
variables or arrays, and vice-versa.

## MAIN OPTIONS:

**-h**, **\--help**

:   Show help and exit.

**-V**, **\--version**

:   Show version and exit.

## ACTIONS:

from_str

:   Escape \'\\\' and \[/\"\\b\\f\\n\\r\\t\] characters as required by
    JSON format.

from_var

:   Output VARNAMES in a JSON object.

type

:   Expect JSON type regarding the begining of JSONTEXT.

to_var

:   Output string to be put into bash variable or array.

 
All actions support a **\--help** option, eg: \$ bl-json from_str
**\--help**

bl-json is also bash library, see: \$ source bl-json **\--help**

# EXEMPLE

```bash
$ bl-json from_var BASH_VERSINFO
```

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

