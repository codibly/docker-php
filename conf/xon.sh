#!/bin/bash

HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')

sudo mv /usr/local/etc/php/conf.d/xdebug.off /usr/local/etc/php/conf.d/xdebug.ini

sudo sed -i "s|xdebug.remote_host=.*|xdebug.remote_host=$HOST_IP|" /usr/local/etc/php/conf.d/xdebug.ini

sudo pkill -o -USR2 php-fpm
