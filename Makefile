# © 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

SHELL := /bin/sh

.POSIX:
.SUFFIXES:
.DELETE_ON_ERROR:

all:: check

check:: build
	reuse lint

all check build clean install uninstall::
	$(MAKE) -C man $@

.PHONY: all check build clean install uninstall

man/%:
	$(MAKE) -C man $*
