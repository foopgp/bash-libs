<!--
© 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>

SPDX-License-Identifier: LGPL-3.0-only
-->

---
title: BL-PGPID
section: 1
header: User Commands
footer: bash-libs 0.3.5
---

# NAME

bl-pgpid - Generate and manage OpenPGP ID, an OpenPGP configuration
providing universal and decentralized civil status to secure your
digital life (emails, git, ssh, avatar, sso, etc.).

# SYNOPSIS

**bl-pgpid** \[*MAIN_OPTIONS*\]\... *ACTION *\[*OPTIONS*\]\...
\[*ARGUMENTS*\]\...

# DESCRIPTION

Generate and manage OpenPGP ID, an OpenPGP configuration providing
universal and decentralized civil status to secure your digital life
(emails, git, ssh, avatar, sso, etc.). It combines the power of OpenPGP
(RFC 9580) with those of others open international standards: POSIX,
ICAO 9303, ISO/IEC 7816, many others RFC.

## MAIN OPTIONS:

**-f**, **\--frontend** PROGRAM

:   Select a frontend program {NONE,whiptail,dialog,zenity} -
    Environment variable: BL_INTERACTIVE_FRONTEND

**-h**, **\--help**

:   Show help and exit.

**-V**, **\--version**

:   Show version and exit.

## ACTIONS:

get

:   Output fingerprints, emails and OpenPGP IDentifier of certificates
    matching NAME\|U4\|U5\|EMAIL.

mrz_to_u4

:   Calculate and output a OpenPGP ID u4, from the Machine Readable Zone
    of an icao9303 passport.

gen_u4

:   Generate OpenPGP ID u4 string. Missing input will be asked
    interactively.

gen_uid

:   Generate a 32bit Unix User ID, from 2\^18 to (2\^31)-2
    (\[262144,2147483646\]).

gen_key

:   Generate an OpenPGP key pair (public and secret) according to
    OpenPGP ID standards.

avatar

:   Extract or add image inside OpenPGP certificate.

email

:   Display and add or revoke emails inside OpenPGP certificate.

token_check

:   Check if security token is correctly configured for OpenPGP ID ; may
    output informations.

certify

:   Certify somebody else, identified by its OpenPGP ID TARGET_U4.

 
All actions support a **\--help** option, eg: \$ bl-pgpid get
**\--help**

bl-pgpid is also bash library, see: \$ source bl-pgpid
**\--help**

# ENVIRONMENT

**BL_INTERACTIVE_FRONTEND**
:   Select the frontend program, between : NONE, whiptail, dialog or zenity.

**BL_PGPID_KEYSERVERS**
:   URLs of OpenPGP keyservers to use, separated by spaces. The first one MUST be HKPS compatible (*hkps://...*), and may be the only one used, depending on context.

**GNUPGHOME**
:   GnuPG home directory, to be used instead of "~/.gnupg".

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# SEE ALSO

[**bash-libs**](../README.md)(7).

# AUTHORS

foopgp <info@foopgp.org>, Jean-Jacques Brucker <jjbrucker@foopgp.org>.

