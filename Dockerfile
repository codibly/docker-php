FROM php:7.1.6-fpm
MAINTAINER Jakub Biernacki <kuba.biernacki@codibly.com>

# INSTALL ESSENTIALS LIBS TO COMPILE PHP EXTENSTIONS
RUN apt-get update && apt-get install -y \
    # for zip ext
    zlib1g-dev \

    # for pg_pgsql ext
    libpq-dev \

    # for soap and xml related ext
    libxml2-dev \

    # for xslt ext
    libxslt-dev \

    # for gd ext
    libjpeg-dev libpng-dev \

    # for intl ext
    libicu-dev

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
  hash \
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
RUN pecl install xdebug
RUN bash -c 'echo -e "\n[xdebug]\nzend_extension=xdebug.so\nxdebug.remote_enable=1\nxdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini'

# COMPOSER
ENV COMPOSER_HOME /usr/local/composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/bin --filename=composer
RUN rm composer-setup.php
RUN bash -c 'echo -e "{ \"config\" : { \"bin-dir\" : \"/usr/local/bin\" } }\n" > /usr/local/composer/composer.json'
RUN echo "export COMPOSER_HOME=/usr/local/composer" >> /etc/bash.bashrc

# INSTALL ROBO TASK RUNNER
RUN composer global require codegyre/robo

# DOWNLOAD SYMFONY INSTALLER
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony

# CLEAN APT AND TMP
RUN apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
