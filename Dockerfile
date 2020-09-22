FROM php:7.4.10-fpm

MAINTAINER Radek Smoczyński <radoslaw.smoczynski@codibly.com>

# INSTALL ESSENTIALS LIBS TO COMPILE PHP EXTENSTIONS
RUN apt-get update && apt-get install -y \
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
    libicu-dev \
    # for mbstring ext
    libonig-dev \
    # openssl
    libssl-dev \
    git \
    htop \
    nano \
    iputils-ping \
    curl \
    sudo \
    passwd \
    sqlite \
    procps \
    iproute2 \
    supervisor \
    cron

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

# INSTALL XDEBUG
RUN pecl install xdebug-beta
RUN bash -c 'echo -e "\n[xdebug]\nzend_extension=xdebug.so\nxdebug.remote_enable=1\nxdebug.remote_connect_back=0\nxdebug.remote_autostart=1\nxdebug.remote_host=" >> /usr/local/etc/php/conf.d/xdebug.ini'

# INSTALL XDEBUG AND ADD FUNCTIONS TO TURN ON/OFF XDEBUG
COPY conf/xoff.sh /usr/bin/xoff
COPY conf/xon.sh /usr/bin/xon

RUN set -x \
    && chmod +x /usr/bin/xoff \
    && chmod +x /usr/bin/xon \
    && mv /usr/local/etc/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.off \
    && echo 'PS1="[\$(test -e /usr/local/etc/php/conf.d/xdebug.off && echo XOFF || echo XON)] $HC$FYEL[ $FBLE${debian_chroot:+($debian_chroot)}\u$FYEL: $FBLE\w $FYEL]\\$ $RS"' | tee /etc/bash.bashrc /etc/skel/.bashrc;

# INSTALL MONGODB
RUN pecl install mongodb
RUN bash -c 'echo extension=mongodb.so > /usr/local/etc/php/conf.d/mongodb.ini'

# COMPOSER
ENV COMPOSER_HOME /usr/local/composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/bin --filename=composer
RUN rm composer-setup.php
RUN bash -c 'echo -e "{ \"config\" : { \"bin-dir\" : \"/usr/local/bin\" } }\n" > /usr/local/composer/composer.json'
RUN echo "export COMPOSER_HOME=/usr/local/composer" >> /etc/bash.bashrc

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --classmap-authoritative


# INSTALL ROBO TASK RUNNER
RUN composer global require consolidation/robo

# INSTALL CODECEPTION
RUN composer global require codeception/codeception

# INSTALL STATIC CODE ANALYSIS, CODE METRICS AND SIMILAR TOOLS
RUN composer global require \
  # PHPCS
  squizlabs/php_codesniffer=3.* \
  # PHPCPD
  sebastian/phpcpd=5.* \
  # PHPLOC
  phploc/phploc=6.* \
  # PDEPEND
  pdepend/pdepend=2.* \
  # PHPMD
  phpmd/phpmd=@stable

# DOWNLOAD SYMFONY INSTALLER
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony

# CLEAN APT AND TMP
RUN apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY PHP.INI SUITABLE FOR DEVELOPMENT
COPY conf/php.ini.development /usr/local/etc/php/php.ini

# CREATE PHP.INI FOR CLI AND TWEAK IT
RUN cp /usr/local/etc/php/php.ini /usr/local/etc/php/php-cli.ini && \
    sed -i "s|memory_limit.*|memory_limit = -1|" /usr/local/etc/php/php-cli.ini

# TWEAK MAIN PHP.INI CONFIG FILE
RUN sed -i "s|upload_max_filesize.*|upload_max_filesize = 128M|" /usr/local/etc/php/php.ini && \
    sed -i "s|post_max_size.*|post_max_size = 128M|" /usr/local/etc/php/php.ini && \
    sed -i "s|max_execution_time.*|max_execution_time = 300|" /usr/local/etc/php/php.ini && \
    sed -i "s|expose_php.*|expose_php = off|" /usr/local/etc/php/php.ini && \
    sed -i "s|memory_limit.*|memory_limit = 3048M|" /usr/local/etc/php/php.ini

# PREPARE USER www-data WITH PROPER ID TO SOLVE FILE PERMISSION ISSUE ON IDE LEVEL
# local user need to have id 1000, in other way this proces need to rearanged on project level

ENV HOME_DIR=/var/www
ENV USER_LOGIN=www-data
ENV USER_ID=1000

RUN usermod -u $USER_ID $USER_LOGIN && \
    groupmod -g $USER_ID $USER_LOGIN && \
    usermod -aG sudo $USER_LOGIN && \
    echo "$USER_LOGIN ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# SYMFONY TWEAK
RUN echo "alias sf='bin/console'" >> $HOME_DIR/.bashrc

# COPY SUPERVISOR CONFIGURATION
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf
RUN chmod 0644 /etc/supervisor/supervisord.conf
