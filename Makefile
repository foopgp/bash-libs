# © 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

SHELL            := /bin/sh
LICENCES_CHECKER := reuse lint
SUB_MAKE_DIRS    := specs man tests

.POSIX:
.SUFFIXES:
.DELETE_ON_ERROR:

all: build

build:
	$(MAKE) -C man

check_licenses:
	RESULT=$$($(LICENCES_CHECKER) 2>&1) || (printf "%s\n" "$$RESULT" && exit 1)

check: check_licenses build

check clean:
	$(MAKE) -C specs $@
	$(MAKE) -C man   $@
	$(MAKE) -C tests $@

html pdf docbook markdown:
	$(MAKE) -C specs $@

install uninstall:
	$(MAKE) -C man   $@

.PHONY: all build check check_licenses clean install uninstall $(SUB_MAKE_DIRS)
.PHONY: phony

$(addsuffix /%, $(SUB_MAKE_DIRS)): phony
	$(MAKE) -C $(patsubst %/$*, %, $@) $*

$(SUB_MAKE_DIRS): %:
	$(MAKE) -C $*
