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
*\_bl_*.

Also all environment variables set when sourcing a bash-libs executable should be
prefixed by *BL_*.

# OPTIONS

All bash-libs exposed functions should support at least *--help* and *--version* to
be passed as a first argument.

All bash-libs executables should also support at least *--help* and *--version*
to be passed as a first argument, even if they are sourced instead of executed.

When sourced, all bash-libs executables should also support a
*--bash-completion* option to be passed as first argument, to load a bash
completion for the given executable.

# DIAGNOSTICS

All bash-libs exposed functions and executables should return zero on normal operation, non-zero on errors.


# FILES


## bl-interactive

Help managing interactive choices

### bl_yesno

Helper for a yes/no question (binary choice)

### bl_chooseinlist

Helper for a single choice in a list (like radiobutton)


## bl-security

Provide some "security" features

### bl_urandom

Output a good random number between 0 and 1<<32,

### bl_shreddir

Recursively shred all files in a directory tree.

### bl_gen_passphrase

Generate a good random passphrase


## bl-log

This executable/library contain only one exposed function: **bl_log**. So it
doesn't implement a function dispatcher and using bl-log as an executable is
*almost* the same thing than using bl_log function.

"*Almost*" nuance: when sourcing bl-log (using it as a bash library), we may pass
some options as arguments, which will be store in some environment variable.
Then such options will remain for following calls of **bl_log** (with no options
passed as arguments).

### bl_log

Wrapper for logger command, which also print pretty logs on stderr.

# EXAMPLES

```bash
 . bl-log --no-act --log-level "6" --log-exit "crit"
 bl_log debug "$FUNCNAME: $@" # This won't be logged (debug <> 7)
 bl_log info "some informations" # This logs (info <> 6)
 bl_log crit "ouch" # This logs then exit(11).
```

```bash
 ./bl-log --help
 . ./bl-log --bash-completion
 ./bl-log --no-act syslog.notice "Nice log !"
```

# SEE ALSO

**bl-log**(1), **bl-interactive**(1).

# AUTHOR/MAINTAINER

Jean-Jacques Brucker

