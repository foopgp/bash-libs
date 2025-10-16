# © 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

TARGETS               := $(wildcard bin/*)

SHELL                 := /bin/sh
LICENCES_CHECKER      := reuse lint
SUB_MAKE_DIRS         := specs man tests

prefix                ?= /usr/local
exec_prefix           ?= $(prefix)
bindir                ?= $(exec_prefix)/bin

BINDIR                := $(DESTDIR)$(bindir)

GIT_DESCRIBE          := git describe --dirty --broken --always
DIRTY_BROKEN          := \(dirty\|broken\)
COMMIT_COUNT          := \([1-9][0-9]*\)
COMMIT_HASH           := \(g[0-9a-f]\+\)
OPTIONAL_DIRTY_BROKEN := \(-$(DIRTY_BROKEN)\|\)
PLUS_POST_TAG_ID      := -e 's/-$(COMMIT_COUNT)-$(COMMIT_HASH)$(OPTIONAL_DIRTY_BROKEN)$$/+\1.\2\3/1'
PLUS_DIRTY_BROKEN     := -e 's/-$(DIRTY_BROKEN)$$/+\1/1'
COMMIT_DESCRIPTION    := $(shell $(GIT_DESCRIBE) | sed $(PLUS_POST_TAG_ID) $(PLUS_DIRTY_BROKEN))

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

install: $(addprefix $(BINDIR)/, $(notdir $(TARGETS)))
	$(MAKE) -C man   $@
	$(MAKE) -C bash-completion   $@

uninstall:
	$(MAKE) -C man   $@
	$(MAKE) -C bash-completion   $@
	$(RM) $(addprefix $(BINDIR)/, $(notdir $(TARGETS)))

install-pre-commit-hook: .git/hooks/pre-commit

.PHONY: all build check check_licenses clean install uninstall $(SUB_MAKE_DIRS)
.PHONY: phony install-pre-commit-hook

$(addsuffix /%, $(SUB_MAKE_DIRS)): phony
	$(MAKE) -C $(patsubst %/$*, %, $@) $*

$(BINDIR)/%: bin/% phony | $(BINDIR)
	sed 's/^\(BL_[A-Z]\+_VERSION=\).*$$/\1"$(COMMIT_DESCRIPTION)"/1' $< > $@
	chmod 755 $@

$(SUB_MAKE_DIRS): %:
	$(MAKE) -C $*

.git/hooks/pre-commit: pre-commit.hook
	cp --interactive $< $@

$(BINDIR):
	mkdir -p $@
