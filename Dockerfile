FROM php:7.1-fpm-alpine

# Build Dependencies
RUN apk update && apk --no-cache add --virtual .build-deps $PHPIZE_DEPS \
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
  icu-dev \
  # PHP general dep
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
	zlib-dev
  
# PHP Extensions
RUN docker-php-ext-install -j$(nproc) iconv
RUN docker-php-ext-install -j$(nproc) mbstring
RUN docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-freetype-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) exif
RUN docker-php-ext-install -j$(nproc) curl dom mcrypt sockets xsl zip soap xmlrpc json
RUN docker-php-ext-install -j$(nproc) tokenizer
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) pdo pgsql
RUN RUN docker-php-ext-configure pdo_pgsql \
 && docker-php-ext-install -j$(nproc) pdo_pgsql

RUN apk del .build-deps

RUN apk add libpng icu-libs libmcrypt libpq libxslt

# Use the default production configuration
RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
