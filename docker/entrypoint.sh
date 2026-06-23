#!/bin/bash
set -e

echo "[entrypoint] Bootstrapping production..."

# Abort if APP_KEY is missing
if [ -z "$APP_KEY" ]; then
    echo "[entrypoint] ERROR: APP_KEY is not set."
    echo "[entrypoint] Generate one with:"
    echo "[entrypoint]   docker run --rm php:8.3-alpine php -r \"echo 'base64:' . base64_encode(random_bytes(32)) . PHP_EOL;\""
    echo "[entrypoint] Then set APP_KEY=<result> in your .env file."
    exit 1
fi

php artisan config:cache
php artisan route:cache
php artisan view:cache
 
# Sync public/ into the shared volume so nginx can serve static assets
echo "[entrypoint] Syncing public assets to shared volume..."
rsync -a --delete --no-group --no-perms --omit-dir-times --exclude='storage' /var/www/html/public/ /var/www/html/public-volume/

# Seed the storage volume with default files on first run.
# The volume mounts over storage/app/public/ hiding the baked-in files,
# so we keep a backup copy at /var/www/html/storage-seed/ and restore on first boot.
if [ -z "$(ls -A /var/www/html/storage/app/public/ 2>/dev/null)" ]; then
    echo "[entrypoint] Storage volume is empty, seeding default files..."
    cp -r /var/www/html/storage-seed/. /var/www/html/storage/app/public/
    echo "[entrypoint] Storage seeded."
fi


# storage:link — guard against non-zero exit if link already exists
#if [ ! -L /var/www/html/public-volume/storage ]; then
#    php artisan storage:link
#fi
 
# Run migrations
echo "[entrypoint] Running migrations..."
php artisan migrate --force
 
echo "[entrypoint] Done. Starting PHP-FPM..."
exec "$@"