FROM php:7.4.1-cli

MAINTAINER Codibly <office@codibly.com>

WORKDIR /opt/app/

ENV USER_LOGIN    www-data
ENV USER_HOME_DIR /home/$USER_LOGIN
ENV APP_DIR       /opt/app

############ PHP-CLI ############

# CREATE WWW-DATA HOME DIRECTORY
RUN set -x \
    && mkdir /home/www-data \
    && chown -R www-data:www-data /home/www-data \
    && usermod -u 1000 --shell /bin/bash -d /home/www-data www-data \
    && groupmod -g 1000 www-data

# INSTALL ESSENTIALS LIBS TO COMPILE PHP EXTENSTIONS
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
        # for zip ext
        zlib1g-dev libzip-dev\
        # for pg_pgsql ext
        libpq-dev \
        # for soap and xml related ext
        libxml2-dev \
        # for xslt ext
        libxslt-dev \
        # for gd ext
        libjpeg-dev libpng-dev \
        # for intl ext
        libicu-dev openssl \
        # for mbstring ext
        libonig-dev \
        # openssl
        libssl-dev \
        # htop for resource monitoring
        htop \
        # for pkill
        procps \
        vim iputils-ping curl iproute2 \
        #
        supervisor

# INSTALL PHP EXTENSIONS VIA docker-php-ext-install SCRIPT
RUN docker-php-ext-install \
  bcmath \
  calendar \
  ctype \
  dba \
  dom \
  exif \
  fileinfo \
  ftp \
  gettext \
  gd \
#  hash \
  iconv \
  intl \
  mbstring \
  opcache \
  pcntl \
  pdo \
  pdo_pgsql \
  pdo_mysql \
  posix \
  session \
  simplexml \
  soap \
  sockets \
  xsl \
  zip

COPY scripts/xoff.sh /usr/bin/xoff
COPY scripts/xon.sh /usr/bin/xon

# INSTALL XDEBUG
RUN set -x \
    && pecl install xdebug-beta \
    && bash -c 'echo -e "\n[xdebug]\nzend_extension=xdebug.so\nxdebug.remote_enable=1\nxdebug.remote_connect_back=0\nxdebug.remote_autostart=1\nxdebug.remote_host=" >> /usr/local/etc/php/conf.d/xdebug.ini' \
    # Add global functions for turn on/off xdebug
    && chmod +x /usr/bin/xoff \
    && chmod +x /usr/bin/xon \
    # turn off xdebug as default
    && mv /usr/local/etc/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.off  \
    && echo 'PS1="[\$(test -e /usr/local/etc/php/conf.d/xdebug.off && echo XOFF || echo XON)] $HC$FYEL[ $FBLE${debian_chroot:+($debian_chroot)}\u$FYEL: $FBLE\w $FYEL]\\$ $RS"' | tee /etc/bash.bashrc /etc/skel/.bashrc

# INSTALL COMPOSER
ENV COMPOSER_HOME /usr/local/composer
# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN set -x \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && rm composer-setup.php \
    && bash -c 'echo -e "{ \"config\" : { \"bin-dir\" : \"/usr/local/bin\" } }\n" > /usr/local/composer/composer.json' \
    && echo "export COMPOSER_HOME=/usr/local/composer" >> /etc/bash.bashrc \
    && composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --classmap-authoritative;

############# CONFIGURE ############
#  TWEAK PHP CONFIG
RUN set -x \
    && mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
    && sed -i "s|memory_limit.*|memory_limit = 2048M|" $PHP_INI_DIR/php.ini \
    && sed -i "s|max_execution_time.*|max_execution_time = 3000|" $PHP_INI_DIR/php.ini \
    && sed -i "s|upload_max_filesize.*|upload_max_filesize = 32M|" $PHP_INI_DIR/php.ini \
    && sed -i "s|post_max_size.*|post_max_size = 48M|" $PHP_INI_DIR/php.ini \
    && sed -i "s|;date.timezone = *|date.timezone = Europe/London|" $PHP_INI_DIR/php.ini \
    && cp $PHP_INI_DIR/php.ini $PHP_INI_DIR/php-cli.ini

RUN set -x \
   && bash -c 'echo "alias sf=bin/console" >> ~/.bashrc'