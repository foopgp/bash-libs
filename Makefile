# © 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

TARGETS          := $(wildcard bin/*)

SHELL            := /bin/sh
INSTALL          := install
INSTALL_PROGRAM  := $(INSTALL)
LICENCES_CHECKER := reuse lint
SUB_MAKE_DIRS    := specs man tests

prefix           ?= /usr/local
exec_prefix      ?= $(prefix)
bindir           ?= $(exec_prefix)/bin

BINDIR           := $(DESTDIR)$(bindir)

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

install: | $(BINDIR)
	$(MAKE) -C man   $@
	$(INSTALL_PROGRAM) $(TARGETS) $(BINDIR)

uninstall:
	$(MAKE) -C man   $@
	$(RM) $(addprefix $(BINDIR)/, $(notdir $(TARGETS)))

install-pre-commit-hook: .git/hooks/pre-commit

.PHONY: all build check check_licenses clean install uninstall $(SUB_MAKE_DIRS)
.PHONY: phony install-pre-commit-hook

$(addsuffix /%, $(SUB_MAKE_DIRS)): phony
	$(MAKE) -C $(patsubst %/$*, %, $@) $*

$(SUB_MAKE_DIRS): %:
	$(MAKE) -C $*

.git/hooks/pre-commit: pre-commit.hook
	cp --interactive $< $@

$(BINDIR):
	mkdir -p $@
