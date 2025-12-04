PREFIX ?= /usr

install:
	# FIX: For GLIBC system with shared-libs. If here is MUSL embed system with static build, then it no needed.
	sed "s|=\"/etc/getip-url.conf\"$$|=\"$(DESTDIR)/etc/getip-url.conf\"|" -i www-get-ip.sh
	sed "s| ulimit -d '100'$$| ulimit -d '2000'|" -i www-get-ip.sh
	sed "s| timeout 2 | timeout 10 |" -i www-get-ip.sh
	sed "s| usleep [0-9]*$$| sleep 0.2|" -i www-get-ip.sh tests/test-myip-urls.sh

	install -Dvm 755 www-get-ip.sh $(DESTDIR)$(PREFIX)/bin/www-get-ip
	install -Dvm 755 tests/test-myip-urls.sh $(DESTDIR)$(PREFIX)/bin/test-myip-urls
	install -Dbvm 644 getip-url.conf $(DESTDIR)/etc/getip-url.conf
	ln -s www-get-ip $(DESTDIR)$(PREFIX)/bin/get-ip
	ln -s www-get-ip $(DESTDIR)$(PREFIX)/bin/ext-ip

check:
	./tests/test-myip-urls.sh ./getip-url.conf

clean:
	rm -f www-get-ip.sh
	rm -f tests/test-myip-urls.sh
	rm -f getip-url.conf

.PHONY: clean
