FROM php:7.1-fpm-alpine

# Build Dependencies
RUN apt-get update && apt-get install -y \
  # gd deps
  freetype-dev \
  libpng-dev \
  libwebp-dev \
  jpeg-dev \
  # mcrypt deps
  libmcrypt-dev \
  # xsl deps
  libxslt-dev
  
# PHP Extensions
RUN docker-php-ext-install -j$(nproc) iconv \
 && docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-freetype-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd \
 && docker-php-ext-install -j$(nproc) mcrypt sockets xsl zip soap xmlrpc

# Use the default production configuration
RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
