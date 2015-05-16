PREFIX = /usr/local

$(PREFIX)/bin/lxrc : lxrc
	cp '$<' '$@'
	chmod 755 '$@'

