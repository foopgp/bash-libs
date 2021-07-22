MAKEDIRS = man


all:
	for md in $(MAKEDIRS) ; do \
		$(MAKE) -C $$md $@ ; \
	done

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
