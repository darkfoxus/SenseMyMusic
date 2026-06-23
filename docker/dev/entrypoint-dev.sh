#!/bin/bash
set -e

cd /var/www

echo "[dev] Bootstrap. Checking dependencies..."

# Install PHP deps if vendor is empty
if [ ! -f vendor/autoload.php ]; then
    echo "[dev] Running composer install..."
    composer install --no-interaction
fi

# Install Node deps if node_modules is empty
if [ -f package.json ] && [ ! -d node_modules/.bin ]; then
    echo "[dev] Running npm install..."
    npm install
fi

# Abort early if APP_KEY is missing — better than a cryptic Laravel error
if [ -z "$APP_KEY" ]; then
    echo "[dev] ERROR: APP_KEY is not set."
    echo "[dev] Run this to generate one:"
    echo "[dev]   docker run --rm php:8.3-alpine php -r \"echo 'base64:' . base64_encode(random_bytes(32)) . PHP_EOL;\""
    echo "[dev] Then set APP_KEY=<result> in your .env file."
    exit 1
fi

# Run migrations
echo "[dev] Running migrations..."
php artisan migrate --force

# Seed database only if explicitly requested
if [ "${RUN_SEEDER:-false}" = "true" ]; then
    echo "[dev] Running seeders..."
    php artisan db:seed --force
fi

# Create storage symlink
php artisan storage:link || true
php artisan optimize:clear

echo "[dev] Bootstrap complete. Starting dev server..."
exec "$@"