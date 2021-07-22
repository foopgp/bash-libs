MANDIR = /usr/share/man

bash-libs.7.gz: ../README.md
	MANDATE="$$(LANG=C git log -1 --format="%ad" --date="format:%d %B %Y" -- $<)" ;\
	[ "$$MANDATE" ] || MANDATE="\1" ;\
	sed "1,6s;^date:\(.*\);date: $$MANDATE;" < $< | pandoc -s -t man | gzip > $@


all: bash-libs.7.gz

clean:
	rm -f bash-libs.7.gz

install: bash-libs.7.gz
	mkdir -p $(DESTDIR)$(MANDIR)/man7
	install -m644 bash-libs.7.gz \
		$(DESTDIR)$(MANDIR)/man7
	#mkdir -p $(DESTDIR)$(MANDIR)/fr/man7
	#install -m644 bash-libs.fr.7.gz \
	#	$(DESTDIR)$(MANDIR)/fr/man7/bash-libs.7.gz

uninstall:
	#rm $(DESTDIR)$(MANDIR)/fr/man7/bash-libs.7.gz
	rm $(DESTDIR)$(MANDIR)/man7/bash-libs.7.gz
