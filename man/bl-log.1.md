<!--
© 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-LOG
section: 1
header: User Commands
footer: bash-libs
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

**-l**, **\--log-level** LEVEL

:   log level:
    emerg\<1=alert\<crit\<3=err\<warning\<5=notice\<info\<7=debug
    (env var: BL_LOGLEVEL)

**-L**, **\--log-exit** LEVELNAME exit level:
emerg\|alert\|crit\|err\|warning\|\... (env var: BL_LOGEXITLNAME)

**-q**, **\--quiet**

:   do not output message to standard error

**-Q**, **\--no-act**

:   do not send message to the logs system (syslog)

**\--color\[=**\<on\|off\|auto\>\]

:   colorize messages sent to standard error (default: auto)

**-h**, **\--help**

:   show this help and exit/return

**-V**, **\--version**

:   show version and exit/return

## Options forwarded to \'logger\':

**-i**

:   log the logger command\'s PID

**\--id\[=**\<id\>\]

:   log the given \<id\>, or otherwise the PID (default \$\$ = logger\'s
    PPID)

**-f**, **\--file** \<file\>

:   log the contents of this file

**-e**, **\--skip-empty**

:   do not log empty lines when processing files

**\--octet-count**

:   use rfc6587 octet counting

**\--prio-prefix**

:   look for a prefix on every line read from stdin

**-S**, **\--size** \<size\>

:   maximum size for a single message

**-t**, **\--tag** \<tag\>

:   mark every line with this tag (default \${0##\*/})

**-n**, **\--server** \<name\>

:   write to this remote syslog server

**-P**, **\--port** \<port\>

:   use this port for UDP or TCP connection

**-T**, **\--tcp**

:   use TCP only

**-d**, **\--udp**

:   use UDP only

**\--rfc3164**

:   use the obsolete BSD syslog protocol

**\--rfc5424\[=**\<snip\>\]

:   use the syslog protocol (the default for remote); \<snip\> can be
    notime, or notq, and/or nohost

**\--sd-id** \<id\>

:   rfc5424 structured data ID

**\--sd-param** \<data\>

:   rfc5424 structured data name=value

**\--msgid** \<msgid\>

:   set rfc5424 message id field

**-u**, **\--socket** \<socket\>

:   write to this Unix socket

**\--socket-errors\[=**\<on\|off\|auto\>\]

:   print connection errors when using Unix sockets

**\--journald\[=**\<file\>\]

:   write journald entry


# ENVIRONMENT VARIABLES

**BL_LOGLEVEL**     Set the level of message to be logged, see --log-level.

**BL_LOGEXITLNAME** Set, by name, the level of message that will rise an exit (like err.h C standard). See --log-exit.

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

