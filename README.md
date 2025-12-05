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

from root with drop privileges
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
- usleep (busybox)

or

- Dash
- Sed,Grep,etc GNU
- Coreutils GNU
- Wget GNU
- sleep (coreutils) replace to: '/usleep 200000/ sleep 0.2/'

---

## Install

$ - 'user'

% - 'root' or replace by 'sudo', e.g, ```sudo cp resolv.conf /etc/```

#### Install under user (safe)
```
$ mkdir ${HOME}/bin ${HOME}/etc
$ make DESTDIR=${HOME} PREFIX= install
$ make check
$ echo 'export PATH=${HOME}/bin:${PATH}' >> .profile
```
or (it not recomended!)

#### Install under root (unsafe)
```
% make DESTDIR=/usr/local PREFIX= install
% make check
```

---

### Manual Install

```
$ mkdir /var/tmp/build/src/
$ cd /var/tmp/build/
$ wget -O www-get-ip.tar.gz https://github.com/nansume/www-get-ip/archive/master.tar.gz
$ gunzip -dc www-get-ip.tar.gz | tar -C src/" -xkf -
$ cd /var/tmp/build/src/www-get-ip-master/

$ sed 's|="/etc/getip-url.conf"$|="/usr/local/etc/getip-url.conf"|' -i www-get-ip.sh
$ sed "s| ulimit -d '[0-9]*'$| ulimit -d '2000'|" -i www-get-ip.sh
$ sed "s| timeout [0-9] | timeout 4 |" -i www-get-ip.sh
$ sed "s| usleep [0-9]*$| sleep 0.2|" -i www-get-ip tests/test-myip-urls

$ chmod +x www-get-ip.sh
$ chmod 0644 getip-url.conf

% cp www-get-ip.sh /usr/local/bin/www-get-ip
% ln -s www-get-ip /usr/local/bin/get-ip
% ln -s www-get-ip /usr/local/bin/ext-ip
% cp getip-url.conf /usr/local/etc/getip-url.conf
```
For testing
```
% chmod +x tests/test-myip-urls.sh
% cp tests/test-myip-urls.sh /usr/local/bin/test-myip-urls
```

---

## Known issues

* No return ip - The site opens in a web browser without error,
	ip address is here, then may be it:

```
% sed "s| ulimit -d '[0-9]*'$| ulimit -d '2000'|" -i /bin/www-get-ip
% sed "s| timeout [0-9] | timeout 4 |" -i /bin/www-get-ip
```
* usleep - no compat, replace to: 'sleep'
	* sleep with fractions of a second, e.g, 'sleep 0.2' - no compat

```
% sed "s| usleep [0-9]*$| sleep 1|" -i /bin/www-get-ip /bin/test-myip-urls
```

---

## License

This work is multi-licensed under either GPLv3 or MIT license or UnLicense.

 * GNU GPLv3 [LICENSE.GPLv3](http://www.gnu.org/licenses/gpl-3.0.html)
 * MIT license [LICENSE.MIT](https://github.com/nansume/www-get-ip/raw/master/LICENSE.MIT)
 * UnLicense [UNLICENSE](https://github.com/nansume/www-get-ip/raw/master/UNLICENSE)
