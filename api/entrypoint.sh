#!/bin/bash

# Запускаем Node.js приложение в фоне
node /usr/share/nginx/html/index.js &

# Проверяем наличие сертификатов
if [ ! -f "/etc/letsencrypt/live/api.mandala-app.online/fullchain.pem" ]; then
  echo "⚠️ Certificates missing! Initializing Certbot..."
  certbot certonly --non-interactive --agree-tos --standalone \
    -d api.mandala-app.online \
    -d api.mandala-app.ru \
    --email sshishkintolik@mail.ru \
    --preferred-challenges http
fi

# Настройка автоматического обновления сертификатов
echo "🔁 Setting up certbot renewal cron job"
echo "0 3 * * * /usr/bin/certbot renew --quiet --webroot -w /var/www/certbot" > /etc/crontabs/root
crond -l 2

# Запускаем Nginx
echo "🚀 Starting Nginx"
exec nginx -g "daemon off;"
