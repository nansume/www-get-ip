# WWW-Get-IP

For get your public ip from one of the websites.
It ipv4-parser extract the ip address out of the myip sites.

---

## Usage


```
Usage: www-get-ip -u USER { -f CONF | -g URL }

Get public ip

        -u      user (drop privileges)
        -f      Config file with urls
        -g      url (get url)
        -h      help
```

---

## Examples

from root
```
% www-get-ip -u USER
```
from user
```
$ www-get-ip
$ www-get-ip -g https://www.showmyipaddress.eu
$ www-get-ip -f /etc/getip-url.conf
```
---

## Features

* Show your external IP address with pseudo-random site from config file or enter your url.
* Support multiple the myip providers/site.
* Now support 68 sites.
* Probably support and other sites.
* For scripts or console/terminal.

---

## Issue

* No support: server MS-IIS a buggy and probably can't working with Wget from Busybox.
    * Then if needed use Wget from GNU (not tested).

---

## Requirements

- Busybox (ash, sed, grep, etc...)
- Wget busybox with include TLS support (without external lib).

---

## Install

```
% sudo make DESTDIR=/usr/local PREFIX= install
```

---

## Manual Install

```
% sudo cp www-get-ip /usr/local/bin/www-get-ip
% sudo ln -s www-get-ip /usr/local/bin/get-ip
% sudo ln -s www-get-ip /usr/local/bin/ext-ip
% sudo cp getip-url.conf /usr/local/etc/getip-url.conf
% sudo chmod +x /usr/local/bin/www-get-ip
% sudo chmod 0644 /usr/local/etc/getip-url.conf
% sudo sed 's|="/etc/getip-url.conf"$|="/usr/local/etc/getip-url.conf"|' -i /usr/local/bin/www-get-ip
% sudo sed "s| ulimit -d '100'$| ulimit -d '1000'|" -i /usr/local/bin/www-get-ip
% sudo sed "s| timeout 2 | timeout 10 |" -i /usr/local/bin/www-get-ip
```
For testing
```
% sudo cp tests/test-urls /usr/local/bin/test-myip-urls
% sudo chmod +x /usr/local/bin/test-myip-urls
```

---

## Known issues

* No return ip - The site opens in a web browser without error, ip address is here,
  then may be it:

```
% sudo sed "s| ulimit -d '100'$| ulimit -d '1000'|" -i /usr/local/bin/www-get-ip
% sudo sed "s| timeout 2 | timeout 10 |" -i /usr/local/bin/www-get-ip
```

---

## License

This work is multi-licensed under either GPLv3 or MIT license or UnLicense.

 * GNU GPLv3 [LICENSE.GPLv3](http://www.gnu.org/licenses/gpl-3.0.html)
 * MIT license [LICENSE.MIT](https://github.com/nansume/www-get-ip/raw/master/LICENSE.MIT)
 * UnLicense [UNLICENSE](https://github.com/nansume/www-get-ip/raw/master/UNLICENSE)
