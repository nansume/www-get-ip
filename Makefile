PREFIX ?= /usr

install:
	install -Dvm 755 www-get-ip.sh $(DESTDIR)$(PREFIX)/bin/www-get-ip
	install -Dvm 755 tests/test-myip-urls.sh $(DESTDIR)$(PREFIX)/bin/test-myip-urls
	install -Dbvm 644 getip-url.conf $(DESTDIR)/etc/getip-url.conf
	ln -s www-get-ip $(DESTDIR)$(PREFIX)/bin/get-ip
	ln -s www-get-ip $(DESTDIR)$(PREFIX)/bin/ext-ip
	sed "s|=\"/etc/getip-url.conf\"$|=\"$(DESTDIR)/etc/getip-url.conf\"|" -i $(DESTDIR)$(PREFIX)/bin/www-get-ip
	sed "s| ulimit -d '100'$| ulimit -d '1000'|" -i $(DESTDIR)$(PREFIX)/bin/www-get-ip
	sed "s| timeout 2 | timeout 10 |" -i $(DESTDIR)$(PREFIX)/bin/www-get-ip

clean:
	rm -f www-get-ip.sh
	rm -f tests/test-myip-urls.sh
	rm -f getip-url.conf

.PHONY: clean
