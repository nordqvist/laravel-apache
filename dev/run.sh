#!/bin/bash

echo "Setup required folders and permissions!"
mkdir -p \
  /app/storage/ \
  /app/storage/framework/sessions \
  /app/storage/framework/views \
  /app/storage/framework/cache \
  /app/storage/app \
  /app/storage/logs \
  /app/storage/uploads
chown -R www-data:www-data /app
chmod -R 775 /app/storage
echo "Cleaning up!"
apt-get clean
rm -r /var/lib/apt/lists/*
php /app/artisan optimize
php /app/artisan config:cache
php /app/artisan route:cache
echo "Starting Apache!"
apache2-foreground
