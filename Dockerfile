FROM php:7.1-fpm-alpine

# Build Dependencies
RUN apk update && apk add \
  # gd deps
  freetype-dev \
  libpng-dev \
  libwebp-dev \
  jpeg-dev \
  # mcrypt deps
  libmcrypt-dev \
  # xsl deps
  libxslt-dev \
  # Postgres deps
  postgresql-dev \
  # Sqlite deps
  sqlite-dev \
  # Intl deps
  icu-dev
  
# PHP Extensions
RUN docker-php-ext-install -j$(nproc) iconv \
 && docker-php-ext-install -j$(nproc) mbstring \
 && docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-freetype-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd \
 && docker-php-ext-install -j$(nproc) exif \
 && docker-php-ext-install -j$(nproc) mcrypt sockets xsl zip soap xmlrpc \
 && docker-php-ext-install -j$(nproc) tokenizer \
 && docker-php-ext-install -j$(nproc) intl \
 && docker-php-ext-install -j$(nproc) pdo pgsql pdo_pgsql sqlite3 pdo_pgsql

# Use the default production configuration
RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
