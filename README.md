## PHP with fpm
PHP docker image based on official one with pre-installed extensions and tools.

### Download
Grab it by running
```
docker pull codibly/php:PHP-VERSION
```
where **PHP-VERSION** (optional, defaults to **latest**) is a desired version of PHP:

* **7** - the very latest stable version (same as **latest**)
* **7.x** - the latest version for 7.x branch
* **7.x.y** - the specific version

available versions:
* 7.1.6
* 7.1.7

### Run
Type
```
docker run --name some-php -d codibly/php:PHP-VERSION
```

That will start php-fpm daemon listening on 9000 port with PID 1.

Logs are written to STDOUT, examine them running

```
docker logs some-php -f
```

### Configuration
Main PHP configuration file can be found at ```/usr/local/etc/php/php.ini``` and extra ones in ```/usr/local/etc/php/conf.d``` directory (every file with **.ini** will be parsed and included). **Provided php.ini file is suitable for development.**

Main php-fpm configuration is here ```/usr/local/etc/php-fpm.conf``` while pools configuration should be place in ```/usr/local/etc/php-fpm.d``` with **.conf** extension.

To tweak anyting you can provide your own configuration file in your derived images or edit existing one and tell php-fpm daemon to reload itself  by sending USR2 signal

```
kill -USR2 1
```

### Pre-installed extensions
* bcmath
* calendar
* ctype
* dba
* dom
* exif
* fileinfo
* ftp
* gettext
* gd
* hash
* iconv
* intl
* mbstring
* mongodb
* opcache
* pcntl
* pdo
* pdo_pgsql
* pdo_mysql
* posix
* session
* simplexml
* soap
* sockets
* xsl
* zip

### Installed PHP software/tools
* [composer](https://www.google.pl/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwiB2JLG14DVAhXmO5oKHWdsBkkQFggnMAA&url=https%3A%2F%2Fgetcomposer.org%2F&usg=AFQjCNH7QQE7wICZatZPhYJLbpp9LfGRww)
* [symfony installer](https://symfony.com/doc/current/setup.html)


### Debugers
* xdebug (configuration file: ```/usr/local/etc/php/conf.d/xdebug.ini```)
* phpdbg
