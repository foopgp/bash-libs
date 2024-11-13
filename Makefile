# © 2021 Jean-Jacques Brucker <jjbrucker@foopgp.org>
#
# SPDX-License-Identifier: LGPL-3.0-only

MAKEDIRS = man


all: check
	for md in $(MAKEDIRS) ; do \
		$(MAKE) -C $$md $@ ; \
	done

check:
	reuse lint

clean:
	for md in $(MAKEDIRS) ; do \
		$(MAKE) -C $$md $@ ; \
	done
	make -C test clean

#install:
#	for md in $(MAKEDIRS) ; do \
#		$(MAKE) -C $$md $@ ; \
#	done
#
#uninstall:
#	for md in $(MAKEDIRS) ; do \
#		$(MAKE) -C $$md $@ ; \
#	done

test: test.forced

test.forced:
	$(MAKE) -C test test

.PHONY: all check clean test test.forced
