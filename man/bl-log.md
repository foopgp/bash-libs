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

# RETURN STATUS

**0**    Successful execution.

**2**    Misuse of arguments (options, parameters, etc.)

# EXIT STATUS

They have been choose to match priority numeric values and according to
https://tldp.org/LDP/abs/html/exitcodes.html:

**168**  When priority's level == 'emerg'

**169**  When priority's level == 'alert', and --log-exit seriousness ≤ 'alert'

**170**  When priority's level == 'crit', and --log-exit seriousness ≤ 'crit'

**171**  When priority's level == 'err' (or deprecated 'error'), and --log-exit seriousness ≤ 'err'.

**172**  When priority's level == 'warning', and --log-exit seriousness ≤ 'warning'.

**173**  When priority's level == 'notice', and --log-exit seriousness ≤ 'notice'.

**174**  When priority's level == 'info', and --log-exit seriousness ≤ 'info'.

**175**  When priority's level == 'debug', and --log-exit seriousness = 'debug'.


# EXAMPLES

```bash
 . bl-log --no-act --log-level "6" --log-exit "crit"
 bl_log debug "$FUNCNAME: $@" # This won't be logged (debug <> 7)
 bl_log info "some informations" # This logs (info <> 6)
 bl_log crit "ouch" # This logs then exit(170).
```

```bash
 ./bl-log --help
 . ./bl-log --bash-completion
 ./bl-log --no-act syslog.notice "Nice log !"
```


# SEE ALSO

**logger**(1), [**bash-libs**](../README.md)(7), sys/syslog.h.


# AUTHOR

Jean-Jacques Brucker

