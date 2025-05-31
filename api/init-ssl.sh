#!/bin/bash

# Директория для сертификатов внутри контейнера
SSL_DIR="/app/ssl-certs"
mkdir -p $SSL_DIR

if [ ! -f "$SSL_DIR/fullchain.pem" ]; then
  echo "Initializing Certbot..."
  certbot certonly --non-interactive --agree-tos --standalone \
    -d api.mandala-app.online \
    -d api.mandala-app.ru \
    --email sshishkintolik@mail.ru \
    --preferred-challenges http \
    --config-dir $SSL_DIR \
    --work-dir $SSL_DIR \
    --logs-dir $SSL_DIR

  # Создаем симлинки для совместимости
  ln -s $SSL_DIR/live/api.mandala-app.online /etc/letsencrypt/live/api.mandala-app.online || true
fi

# Настройка автоматического обновления
echo "0 3 * * * certbot renew --quiet --standalone --post-hook 'pkill -SIGHUP node'" > /etc/crontabs/root
crond
