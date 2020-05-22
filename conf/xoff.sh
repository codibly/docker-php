#!/bin/bash

sudo mv /usr/local/etc/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.off

sudo pkill -o -USR2 php-fpm
