FROM php:7.3-fpm-alpine

# Build Dependencies
RUN apk update && apk --no-cache add --virtual .build-deps $PHPIZE_DEPS \
  freetype-dev \
  libpng-dev \
  libwebp-dev \
  jpeg-dev \
  libmcrypt-dev \
  autoconf \
  apache2-dev \
  aspell-dev \
  bison \
  bzip2-dev \
  curl-dev \
  db-dev \
  enchant-dev \
  freetds-dev \
  freetype-dev \
  gdbm-dev \
  gettext-dev \
  gmp-dev \
  icu-dev \
  imap-dev \
  krb5-dev \
  libedit-dev \
  libical-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libressl-dev \
  libsodium-dev \
  libwebp-dev \
  libxml2-dev \
  libxpm-dev \
  libxslt-dev \
  libzip-dev \
  net-snmp-dev \
  openldap-dev \
  pcre-dev \
  postgresql-dev \
  re2c \
  recode-dev \
  sqlite-dev \
  tidyhtml-dev \
  unixodbc-dev \
  zlib-dev \
  imagemagick-dev
  
# PHP Extensions
RUN docker-php-source extract
RUN docker-php-ext-install -j$(nproc) iconv mbstring curl dom sockets xsl zip soap xmlrpc json posix zip
RUN docker-php-ext-install -j$(nproc) fileinfo bz2 bcmath tokenizer intl pcntl
# RUN docker-php-ext-install -j$(nproc) xmlreader xmlwriter             
RUN docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-freetype-dir=/usr/include/ --with-xpm-dir=/usr/include/ --enable-gd-native-ttf --enable-gd-jis-conv \
 && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) exif
RUN docker-php-ext-install -j$(nproc) pdo pgsql
RUN docker-php-ext-configure pdo_pgsql \
 && docker-php-ext-install -j$(nproc) pdo_pgsql \
 && docker-php-ext-enable opcache

# install apcu
RUN pecl install apcu \
    && docker-php-ext-enable apcu

#install PHP Imagick ext
RUN pecl install imagick && docker-php-ext-enable imagick

# Delete source & builds deps so it does not hang around in layers taking up space
RUN apk del .build-deps \
    && docker-php-source delete

RUN apk add libpng icu-libs libmcrypt libpq libxslt libjpeg-turbo libzip libxml2 zlib libbz2 libwebp libxpm freetype imagemagick bash sudo nano

# Use the default production configuration
RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Change OPCache settings
RUN sed -i 's/;opcache.enable=1/opcache.enable=1/g' $PHP_INI_DIR/php.ini
RUN sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=1/g' $PHP_INI_DIR/php.ini
RUN sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g' $PHP_INI_DIR/php.ini
RUN sed -i 's/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g' $PHP_INI_DIR/php.ini
RUN sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=128/g' $PHP_INI_DIR/php.ini
RUN sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' $PHP_INI_DIR/php.ini
RUN sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/g' $PHP_INI_DIR/php.ini

# Change user of PHP-FPM
RUN apk add shadow
RUN groupadd -g 911 app
RUN useradd -u 911 -g 911 -s /bin/ash -m app \
 && usermod -G users app
 
RUN sed -i 's/user = www-data/user = app/g' /usr/local/etc/php-fpm.d/www.conf
RUN sed -i 's/group = www-data/group = app/g' /usr/local/etc/php-fpm.d/www.conf

# Clean up apk cache
RUN rm -rf /var/cache/apk/*


