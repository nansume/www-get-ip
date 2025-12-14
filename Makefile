PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
CONFDIR ?= $(PREFIX)/etc

install:
	[ -x /bin/usleep ] || sed "s| usleep [0-9]*$$| sleep 1|" -i www-get-ip.sh tests/test-myip-urls.sh

	sed "s|=\"/etc/getip-url.conf\"$$|=\"$(CONFDIR)/getip-url.conf\"|" -i www-get-ip.sh
	install -Dvm 755 www-get-ip.sh $(DESTDIR)$(BINDIR)/www-get-ip
	install -Dvm 755 tests/test-myip-urls.sh $(DESTDIR)$(BINDIR)/test-myip-urls
	install -Dbvm 644 getip-url.conf $(CONFDIR)/getip-url.conf
	ln -s www-get-ip $(DESTDIR)$(BINDIR)/get-ip

check:
	./tests/test-myip-rand.sh ./getip-url.conf 4

clean:
	rm -f www-get-ip.sh tests/test-myip-urls.sh getip-url.conf
