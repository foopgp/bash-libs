---
title: BL-LOG
section: 1
header: User Commands
footer: bash-libs
date: July 2021
---

# NAME

bl-log - Wrapper for logger command, which also print pretty logs on stderr.

# SYNOPSIS

**bl-log** [*OPTIONS*]... *PRIORITY* [*MESSAGE*]...

# DESCRIPTION

This executable/library exposes only one exposed function: **bl_log()**. So it
doesn't implement a function dispatcher and using **bl-log** as an executable is
*almost* the same thing than using **bl_log()** function.

"*Almost*" nuance: when sourcing **bl-log** (using it as a bash library), we may pass
some options as arguments, which will be store in some environment variable.
Then such options will remain for following calls of **bl_log()** (with no options
passed as arguments).

# OPTIONS

# ENVIRONMENT VARIABLES

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.


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

**logger**(1), [**bash-libs**](../README.me)(7).


# AUTHOR

Jean-Jacques Brucker

