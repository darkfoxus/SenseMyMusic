# =============================================================================
# Stage 1 — Frontend assets
# =============================================================================
FROM node:20-alpine AS frontend

WORKDIR /app

COPY app_src/package.json app_src/package-lock.json ./
COPY app_src/vite.config.js app_src/tailwind.config.js app_src/postcss.config.js ./
RUN npm ci

COPY app_src/resources ./resources
COPY app_src/public ./public

RUN npm run build

# =============================================================================
# Stage 2 — PHP dependencies
# =============================================================================
FROM composer:2.7 AS vendor

WORKDIR /app

COPY app_src/composer.json app_src/composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader

# =============================================================================
# Stage 3 — Final production image (PHP-FPM)
# =============================================================================
FROM php:8.3-fpm-alpine AS production

RUN apk add --no-cache \
        bash \
        curl \
        rsync \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libzip-dev \
        oniguruma-dev \
        icu-dev \
        shadow \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache

COPY docker/php/php.ini     /usr/local/etc/php/conf.d/custom.ini
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN groupmod -g 1000 www-data && usermod -u 1000 www-data

WORKDIR /var/www/html

# Copy Laravel source
COPY --chown=www-data:www-data app_src/ .

# Pull compiled frontend assets from Stage 1
COPY --from=frontend --chown=www-data:www-data /app/public/build ./public/build

# Pull vendor from Stage 2
COPY --from=vendor --chown=www-data:www-data /app/vendor ./vendor

RUN mkdir -p storage/framework/{sessions,views,cache} \
             storage/logs \
             bootstrap/cache \
             public-volume \
    && cp -r storage/app/public storage-seed \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chmod 777 public-volume

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www-data
EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
