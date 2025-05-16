#!/bin/bash

# Проверяем наличие сертификатов
if [ ! -d "/etc/letsencrypt/live/mandala-app.online" ]; then
  echo "Initializing Certbot..."
  certbot certonly --non-interactive --agree-tos --standalone \
    -d mandala-app.online \
    -d mandala-app.ru \
    --email sshishkintolik@mail.ru \
    --preferred-challenges http
fi

# Настройка автоматического обновления
echo "0 3 * * * /usr/bin/certbot renew --quiet --post-hook 'nginx -s reload'" >> /etc/crontabs/root

# Запуск cron и Nginx
crond && nginx -g 'daemon off;'
