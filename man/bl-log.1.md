<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-LOG
section: 1
header: User Commands
footer: bash-libs 0.3.12
---

# NAME

bl-log - Wrapper for logger command, which also print pretty logs on
stderr.

# SYNOPSIS

**bl-log** \[*OPTIONS*\]\... *PRIORITY *\[*MESSAGE*\]\...

# DESCRIPTION

Wrapper for logger command, which also print pretty logs on stderr.
PRIORITY is a \"facility.level\" pair. The default facility is
\[user\]=1. Levels: declare **-Ar** BL_LOGLEVELS=(\[warning\]=\"4\"
\[error\]=\"3\" \[err\]=\"3\" \[info\]=\"6\" \[debug\]=\"7\"
\[notice\]=\"5\" \[alert\]=\"1\" \[crit\]=\"2\" \[emerg\]=\"0\" ) If
PRIORITY\'s level is under BL_LOGLEVEL=7, don\'t log anything. If
PRIORITY\'s level name is more serious than BL_LOGEXITLNAME=emerg,
exit(8+\'PRIORITY\'s level\') If there is no MESSAGE in command line,
read it from stdin.

## OPTIONS:

**-l**, **\--log-level** LEVEL

:   log level:
    emerg\<1=alert\<crit\<3=err\<warning\<5=notice\<info\<7=debug
    (current: 7)

**-L**, **\--log-exit** LEVELNAME exit level:
emerg\|alert\|crit\|err\|warning\|\... (current: emerg )

**-q**, **\--quiet**

:   do not output message to standard error

**-Q**, **\--no-act**

:   do not send message to the logs system (syslog)

**\--color\[=**\<on\|off\|auto\>\]

:   colorize messages sent to standard error (default: auto)

**-h**, **\--help**

:   Show help and exit/return

**-V**, **\--version**

:   Show version and exit/return

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

bl-log is also bash library, see: \$ source bl-log **\--help**

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

