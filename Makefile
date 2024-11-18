# © 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

SHELL            := /bin/sh
LICENCES_CHECKER := reuse lint
SUB_MAKE_DIRS    := specs man tests

.POSIX:
.SUFFIXES:
.DELETE_ON_ERROR:

all: check

check: check_licenses build

check_licenses:
	RESULT=$$($(LICENCES_CHECKER) 2>&1) || (printf "%s\n" "$$RESULT" && exit 1)

check build clean:
	$(MAKE) -C specs $@
	$(MAKE) -C man   $@
	$(MAKE) -C tests $@

install uninstall:
	$(MAKE) -C man   $@

.PHONY: all specs check check_licenses build clean install uninstall phony

$(addsuffix /%, $(SUB_MAKE_DIRS)): phony
	$(MAKE) -C $(patsubst %/$*, %, $@) $*
