---
title: BL-SECURITY
section: 1
header: User Commands
footer: bash-libs
date: July 2021
---

# NAME

bl-security - Provide some "security" features. Functions:

# SYNOPSIS

**bl-security** [*OPTIONS*]... *ACTION* [*ACTION_ARGUMENTS*]...

# DESCRIPTION

This executable/library exposes 3 functions: **bl_urandom()**,
**bl_shred_path()**, and **bl_gen_passphrase()**.

# GENERAL OPTIONS

**-h**, **--help**
:  print help and exit/return

**-V**, **--version**
:  show version and exit/return

# ACTIONS / FUNCTIONS

**urandom** / **bl_urandom()**
:  Output a good random number between 0 and 1<<32,

**shred-path** / **bl_shred_path()**
:  Recursively shred all files in given path(|s)

**gen-passphrase** / **bl_gen_passphrase()**
:  Generate a good random passphrase

# SPECIFIC OPTIONS

# ENVIRONMENT VARIABLES

# DIAGNOSTICS

Returns zero on normal operation, non-zero on errors.

# EXAMPLES


# SEE ALSO

**shred**(1), **aspell**(1), [**bl-interactive**](bl-interactive.md)(1), [**bash-libs**](../README.me)(7).


# AUTHOR

Jean-Jacques Brucker

