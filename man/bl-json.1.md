<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-JSON
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-json - manual page for bl-json 0.0.4

# SYNOPSIS

**bl-json** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Use jq (Command-line JSON processor) to convert json data to bash
variables or arrays, and vice-versa.

# OPTIONS

**-h**, **\--help**

:   show this help and exit/return

**-V**, **\--version**

:   show version and exit/return

## Actions:

from_str

:   Escape \"\\\" and \[/\"\\b\\f\\n\\r\\t\] characters as required by
    JSON format.

from_var

:   Output content of VARNAME in a JSON object.

type

:   Expect JSON type regarding the begining of JSONTEXT.

to_var

:   Output string to be put into bash variable or array.

 
All actions support a **\--help** options, eg: \$ bl-json ACTION
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

