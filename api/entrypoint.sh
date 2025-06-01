#!/bin/bash

# Проверяем наличие сертификатов
if [ ! -f "/etc/letsencrypt/live/api.mandala-app.online/fullchain.pem" ]; then
  echo "⚠️ Certificates missing! Initializing Certbot..."
  certbot certonly --non-interactive --agree-tos --webroot \
    --webroot-path /var/www/certbot \
    -d api.mandala-app.online \
    -d api.mandala-app.ru \
    --email sshishkintolik@mail.ru \
    --preferred-challenges http
fi

echo "🔁 Setting up certbot renewal cron job"
echo "0 3 * * * /usr/bin/certbot renew --quiet --webroot -w /var/www/certbot" > /etc/crontabs/root
crond -l 2

echo "🚀 Starting Nginx"
exec nginx -g "daemon off;"
