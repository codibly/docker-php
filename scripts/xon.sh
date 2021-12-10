#!/bin/bash
# usage: xon client_host
# or just: xon (then client host will be taken from host and client port will be default 9003)

HOST_IP=$(/sbin/ip route | awk '/default/ { print $3 }')

mv /usr/local/etc/php/conf.d/xdebug.off /usr/local/etc/php/conf.d/xdebug.ini

sed -i "s|xdebug.client_host=.*|xdebug.client_host=$HOST_IP|" $PHP_INI_DIR/conf.d/xdebug.ini

pkill -o -USR2 php-fpm
