# © 2025 Jean-Jacques Brucker <jjbrucker@foopgp.org>
# SPDX-License-Identifier: LGPL-3.0-only

TARGETS           := $(basename $(wildcard bl-*))

prefix            ?= /usr/local
datarootdir       ?= $(prefix)/share
completiondir     ?= $(datarootdir)/bash-completion/completions

COMPLETIONDIR     := $(DESTDIR)$(completiondir)
DEST_TARGETS      := $(foreach ITEM, $(TARGETS), \
                       $(COMPLETIONDIR)/$(ITEM))
DEST_TARGETS_DIRS := $(sort $(dir $(DEST_TARGETS)))

SHELL             := /bin/sh
INSTALL           := install
INSTALL_DATA      := $(INSTALL) --mode 644

.POSIX:
.SUFFIXES:
.DELETE_ON_ERROR:

all:

build:

check:

clean:

install: build | $(DEST_TARGETS_DIRS)
	-$(foreach ITEM, $(DEST_TARGETS), \
	   $(INSTALL_DATA) $(notdir $(ITEM)) $(dir $(ITEM)) &&) true

uninstall:
	$(RM) $(DEST_TARGETS)

.PHONY: all build clean install uninstall

$(DEST_TARGETS_DIRS):
	-mkdir -p $@
