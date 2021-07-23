MANDIR = /usr/share/man

.PHONY: all clean install uninstall

%.1.gz: %.md
	MANDATE="$$(LANG=C git log -1 --format="%ad" --date="format:%d %B %Y" -- $<)" ;\
	[ "$$MANDATE" ] || MANDATE="\1" ;\
	sed "1,6s;^date:\(.*\);date: $$MANDATE;" < $< | pandoc -s -t man | gzip > $@

bash-libs.7.gz: ../README.md
	MANDATE="$$(LANG=C git log -1 --format="%ad" --date="format:%d %B %Y" -- $<)" ;\
	[ "$$MANDATE" ] || MANDATE="\1" ;\
	sed "1,6s;^date:\(.*\);date: $$MANDATE;" < $< | pandoc -s -t man | gzip > $@

all: bash-libs.7.gz bl-log.1.gz bl-interactive.1.gz bl-security.1.gz

clean:
	rm -f bash-libs.7.gz bl-*.1.gz

install: bash-libs.7.gz bl-log.1.gz bl-interactive.1.gz bl-security.1.gz
	mkdir -p $(DESTDIR)$(MANDIR)/man{1,7}
	install -m644 bash-libs.7.gz \
		$(DESTDIR)$(MANDIR)/man7
	install -m644 bl-*.1.gz \
		$(DESTDIR)$(MANDIR)/man1
	#mkdir -p $(DESTDIR)$(MANDIR)/fr/man7
	#install -m644 bash-libs.fr.7.gz \
	#	$(DESTDIR)$(MANDIR)/fr/man7/bash-libs.7.gz

uninstall:
	rm $(DESTDIR)$(MANDIR)/man7/bash-libs.7.gz
	rm $(DESTDIR)$(MANDIR)/man1/bl-log.gz
	rm $(DESTDIR)$(MANDIR)/man1/bl-interactive.gz
	rm $(DESTDIR)$(MANDIR)/man1/bl-security.1.gz
	#rm $(DESTDIR)$(MANDIR)/fr/man7/bash-libs.7.gz
