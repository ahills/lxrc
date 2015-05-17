PREFIX = /usr/local

DESTBIN = $(PREFIX)/bin/lxrc
DESTMAN = $(PREFIX)/share/man/man1/lxrc.1

install : $(DESTBIN) $(DESTMAN)

$(DESTBIN) : lxrc
	cp '$<' '$@'
	chmod 755 '$@'

$(DESTMAN) : lxrc.1
	cp '$<' '$@'
	chmod 644 '$@'

