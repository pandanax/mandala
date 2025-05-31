#!/bin/bash
set -e  # Прерывать выполнение при ошибках

# Директории для сертификатов
SSL_DIR="/app/ssl-certs"
LIVE_DIR="$SSL_DIR/live/api.mandala-app.ru"  # Используем единый домен
mkdir -p "$SSL_DIR"

# Проверяем наличие сертификатов
if [ ! -f "$LIVE_DIR/fullchain.pem" ]; then
  echo "Initializing Certbot..."

  # Убиваем процессы, которые могут занимать 80/443 порты
  pkill -f nginx || true
  pkill -f certbot || true
  sleep 2

  # Получаем сертификаты
  certbot certonly --non-interactive --agree-tos --standalone \
    -d api.mandala-app.ru \
    --email sshishkintolik@mail.ru \
    --config-dir "$SSL_DIR" \
    --work-dir "$SSL_DIR" \
    --logs-dir "$SSL_DIR" \
    --preferred-challenges http \
    --force-renewal

  # Проверяем результат
  if [ ! -f "$LIVE_DIR/fullchain.pem" ]; then
    echo "ERROR: Certificate generation failed!"
    ls -la "$LIVE_DIR" || true
    exit 1
  fi
fi

# Создаем симлинки для Node.js приложения
mkdir -p /etc/letsencrypt/live/
ln -sf "$LIVE_DIR" "/etc/letsencrypt/live/api.mandala-app.ru" || true

# Настройка автоматического обновления
echo "0 3 * * * /usr/bin/certbot renew --quiet --standalone --post-hook '/usr/bin/pkill -SIGHUP node'" > /etc/crontabs/root
chmod 600 /etc/crontabs/root

# Запускаем cron в фоне
crond -b -L /var/log/cron.log

echo "SSL initialization completed successfully"
