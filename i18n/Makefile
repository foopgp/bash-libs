# © 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

prefix            ?= /usr/local
datarootdir       ?= $(prefix)/share
localedir         ?= $(datarootdir)/locale

PO_FILES          := $(shell find ../share/locale -name "*.po")
MO_FILES          := $(patsubst %.po, %.mo, $(PO_FILES))

LOCALEDIR         := $(DESTDIR)$(localedir)
DEST_TARGETS      := $(foreach ITEM, $(MO_FILES), \
                       $(LOCALEDIR)/$(subst ../share/locale,,$(ITEM)))
DEST_TARGETS_DIRS := $(sort $(dir $(DEST_TARGETS)))

SHELL             := /bin/sh
INSTALL           := install
INSTALL_DATA      := $(INSTALL) --mode 644

.POSIX:
.SUFFIXES:
.DELETE_ON_ERROR:

all: update build

update:
	@set -x ; for file in ../bin/bl-* ; do\
		bash --dump-po-strings $$file ;\
	done | msguniq > bashlibs.pot ;\
	for file in $(PO_FILES) ; do\
		msgmerge --update $$file bashlibs.pot ;\
	done

build: $(MO_FILES)

check: build

clean:
	$(RM) $(MO_FILES)

install: build | $(DEST_TARGETS_DIRS) $(DEST_TARGETS)

uninstall:
	$(RM) $(DEST_TARGETS)

.PHONY: all update build clean install uninstall

$(MO_FILES):
	-msgfmt $(patsubst %.mo, %.po, $@) -o $@

$(DEST_TARGETS_DIRS):
	-mkdir -p $@

$(DEST_TARGETS):
	$(INSTALL_DATA) $(subst $(LOCALEDIR),../share/locale,$@) $@
