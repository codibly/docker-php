FROM php:7.1.18-fpm
LABEL maimaintainer="Jakub Biernacki <kuba.biernacki@codibly.com>, Andrzej Piszczek <andrzej.piszczek@codibly.com>"

# INSTALL ESSENTIALS LIBS TO COMPILE PHP EXTENSTIONS
RUN apt-get update && apt-get install -y \
    #for openssl/ssl.h file
    libssl-dev \
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
# TURN OFF XDEBUG AS DEFAULT
COPY php-config/xdebug.ini /usr/local/etc/php/conf.d/xdebug.off

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

# INSTALL FOR SPEED UP COMPOSER
RUN composer global require hirak/prestissimo

# INSTALL ROBO TASK RUNNER
RUN composer global require consolidation/robo

# INSTALL CODECEPTION
RUN composer global require codeception/codeception

# INSTALL STATIC CODE ANALYSIS, CODE METRICS AND SIMILAR TOOLS
RUN composer global require \
  # PHPCS
  squizlabs/php_codesniffer=3.* \
  # PHPCPD
  sebastian/phpcpd=4.* \
  # PHPLOC
  phploc/phploc=4.* \
  # PDEPEND
  pdepend/pdepend=2.* \
  # PHPMD
  phpmd/phpmd=@stable

# DOWNLOAD SYMFONY INSTALLER
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony

# CLEAN APT AND TMP
RUN apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY PHP.INI SUITABLE FOR DEVELOPMENT
COPY php-config/php.ini.development /usr/local/etc/php/php.ini
