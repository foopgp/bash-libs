<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-MARKDOWN
section: 1
header: User Commands
footer: bash-libs
---

# NAME

bl-markdown - manual page for bl-markdown 0.1.3

# SYNOPSIS

**bl-markdown** \[*OPTIONS*\]\... *ACTION *\[*ACTION_ARGUMENTS*\]\...

# DESCRIPTION

Manipulate \[markdown\](https://en.wikipedia.org/wiki/Markdown). Today,
only converts: markdown arrays \<\> bash arrays.

# OPTIONS

**-h**, **\--help**

:   show this help and exit/return

**-V**, **\--version**

:   show version and exit/return

## Actions:

md_arraytobash

:   Expect stdin to be a markdwon array (with or whithout header), and
    convert each line of this array to a \"declare **-A** \...\"
    statement to be loaded with eval.

md_arrayfrombash

:   Expect stdin to be lines of \"declare **-A** \...\" statement with
    the identical indexes/fieldnames.

 
All actions support a **\--help** options, eg: \$ bl-markdown
ACTION **\--help**

bl-markdown is also bash library, see: \$ source bl-markdown
**\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

