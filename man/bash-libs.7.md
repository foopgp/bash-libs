<!--
© 2021-2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BASH-LIBS
section: 7
header: Miscellaneous informations
footer: bash-libs
---

# NAME

bash-libs - set of tools which may also be sourced as bash libraries

# EXECUTABLES/LIBRARIES

## bl-pgpid

Generate foopgp identifiers, like *udid4* to identify world-wide humans, or a fixed Unix User ID for each of them.

See [**bl-pgpid**](bl-pgpid.1.md)(1) manual for more details.

## bl-dji

Manage djis (Ɉ), also known as foopgp tokens.

See [**bl-dji**](bl-dji.1.md)(1) manual for more details.

## bl-foopgp

Calculate how many foopgp token (Ɉ) may be created for each cotisations to the the foopgp association.

See [**bl-foopgp**](bl-foopgp.1.md)(1) manual for more details.

## bl-json

Use jq (Command-line JSON processor) to convert json data to bash variables or arrays, and vice-versa.

See [**bl-json**](bl-json.1.md)(1) manual for more details.

## bl-interactive

Help managing interactive choices, while supporting multiple frontends: NONE, whiptail or dialog.

See [**bl-interactive**](bl-interactive.1.md)(1) manual for more details.

## bl-markdown

Manipulate [markdown](https://en.wikipedia.org/wiki/Markdown). Today, only converts: markdown arrays <> bash arrays.

See [**bl-markdown**](bl-markdown.1.md)(1) manual for more details.

## bl-security

Provide some "security" features.

See [**bl-security**](bl-security.1.md)(1) manual
for more details.

## bl-log

Wrapper for logger command, which also print pretty logs on stderr.

See [**bl-log**](bl-log.1.md)(1) manual for more details.


# DEVELOPER NOTES

Bash executables heavily use the fact that **${BASH_SOURCE[0]}** differs from **$0** when
sourced.

All bash-libs executables should be prefixed with «bl-», while all bash-libs
exposed functions should be prefixed with «bl_», and functions which are intended
to be use only internally should be prefixed with «\_bl_».

Also all environment variables set when sourcing a bash-libs executable should be
prefixed by «BL_».

All bash-libs exposed functions should support at least *--help* and *--version* to
be passed as a first argument.

All bash-libs executables should also support at least *--help* and *--version*
to be passed as a first argument, even if they are sourced instead of executed.

When sourced, all bash-libs executables should also support a
*--bash-completion* option to be passed as first argument, to load a bash
completion for the given executable.

All bash-libs exposed functions and executables should return zero on normal operation, non-zero on errors.


# SEE ALSO

[**bl-interactive**](bl-interactive.1.md)(1), [**bl-security**](bl-security.1.md)(1), [**bl-log**](bl-log.1.md)(1).

# AUTHORS/MAINTAINERS

* Jean-Jacques BRUCKER
* Henri GEIST

