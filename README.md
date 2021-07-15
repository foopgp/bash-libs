---
title: BASH-LIBS
section: 7
header: Miscellaneous informations
footer: bash-libs
date: July 2021
---

# NAME

bash-libs - set of bash executables which may also be sourced as libraries


# DESCRIPTION

bash-libs is a set of bash-written executables which only expose their variables
and functions if sourced.

Such executables heavily use the fact that **$BASH_SOURCE** differs from **$0** when
sourced.

All bash-libs executables should be prefixed with *bl-*, while all bash-libs
exposed functions should be prefixed with *bl_*.

# ENVIRONMENT VARIABLES

While all bash-libs *exposed* functions should be prefixed with *bl_*, bash-libs
functions which are intended to be use only *internally* should be prefixed with
*_bl_*.

Also all environment variables set when sourcing a bash-libs executable should be
prefixed by *BL_*.

# OPTIONS

All bash-libs exposed functions should support at least *--help* and *--version* to
be passed as a first argument.

All bash-libs executables should also support at least *--help* and *--version*
to be passed as a first argument, even if they are sourced instead of executed.

# DIAGNOSTICS

All bash-libs exposed functions and executables should return zero on normal operation, non-zero on errors.

# FILES

## pl-log

This executable/library contain only one exposed function: **pl_log**. So it doesn't implement a function
dispatcher and while using pl-log as an executable is *almost* the same thing than
using pl_log function.

"*Almost*" nuance: when sourcing pl-log (using it as a bash library), we may pass
some options as arguments, which will be store in some environment variable.
Then such options will remain for following calls of **pl_log** (with no options
passed as arguments).

### pl_log

Wrapper for logger command, which also print pretty logs on stderr.

## pl-interactive

This executable/library doesn't handle (yet) any special option.

### pl_yesno

Helper for a yes/no question (binary choice)

### pl_chooseinlist

Helper for a single choice in a list (like radiobutton)

# EXAMPLE

```bash
 . pl-log --no-act --log-level "6" --log-exit "crit"
 pl_log debug "$FUNCNAME: $@" # This won't be logged (debug <> 7)
 pl_log info "some informations" # This logs (info <> 6)
 pl_log crit "ouch" # This logs then exit(11).
```

# SEE ALSO

**pl-log**(1), **pl-interactive**(1).

# AUTHOR/MAINTAINER

Jean-Jacques Brucker

