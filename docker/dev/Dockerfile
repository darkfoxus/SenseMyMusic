FROM php:8.4-fpm-alpine

# --- System deps + PHP extensions ---
RUN apk add --no-cache \
        bash \
        curl \
        git \
        unzip \
        autoconf \
        make \
        g++ \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libzip-dev \
        oniguruma-dev \
        icu-dev \
        libpq-dev \
        mariadb-dev \
        nodejs \
        npm \
        shadow \
        linux-headers \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_pgsql \
        pgsql \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# --- Composer ---
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# --- Dev PHP config ---
COPY docker/dev/php-dev.ini /usr/local/etc/php/conf.d/dev.ini
COPY docker/dev/xdebug.ini  /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /var/www

# so that vendor can be writen by the user USER www-data
RUN mkdir -p \
/var/www/vendor \
/var/www/storage \
/var/www/bootstrap/cache

COPY docker/dev/entrypoint-dev.sh /entrypoint-dev.sh
RUN chmod +x /entrypoint-dev.sh

# Remove USER www-data from Dockerfile — let entrypoint handle it
EXPOSE 9000

ENTRYPOINT ["/entrypoint-dev.sh"]
CMD ["php-fpm"]