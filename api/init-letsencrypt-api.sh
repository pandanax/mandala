#!/bin/bash

if [ ! -d "/etc/letsencrypt/live/api.mandala-app.online" ]; then
  echo "Initializing Certbot..."
  certbot certonly --non-interactive --agree-tos --standalone \
    -d api.mandala-app.online \
    -d api.mandala-app.ru \
    --email sshishkintolik@mail.ru \
    --preferred-challenges http
fi

# Настройка автоматического обновления
echo "0 3 * * * /usr/bin/certbot renew --quiet --post-hook 'nginx -s reload'" >> /etc/crontabs/root

# Запуск cron и Nginx (оба демона одновременно)
crond &
exec nginx -g 'daemon off;'
