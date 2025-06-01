#!/bin/bash

# Директория с сертификатами (должна монтироваться в контейнер)
CERT_DIR="/etc/letsencrypt/live/api.mandala-app.online"

# Если сертификаты уже есть, пропускаем генерацию
if [ -f "$CERT_DIR/fullchain.pem" ]; then
    echo "✅ Certificates already exist. Skipping Certbot..."
else
    echo "⚠️ Certificates missing! Initializing Certbot (staging mode)..."

    # Используем --staging для тестов (убрать в продакшене)
    certbot certonly --non-interactive --agree-tos --webroot \
        --webroot-path /var/www/certbot \
        --staging \
        -d api.mandala-app.online \
        -d api.mandala-app.ru \
        --email sshishkintolik@mail.ru \
        --preferred-challenges http

    # Если сертификаты получены, копируем их в нужную директорию
    if [ -f "/etc/letsencrypt/live/api.mandala-app.online/fullchain.pem" ]; then
        echo "🔑 Certificates generated successfully!"
    else
        echo "❌ Failed to generate certificates. Starting Nginx without HTTPS..."
        # Запускаем Nginx без HTTPS (проксирует HTTP на 3000 порт)
        sed -i '/listen 443/d' /etc/nginx/conf.d/default.conf
    fi
fi

# Настраиваем крон для обновления сертификатов
echo "🔁 Setting up certbot renewal cron job"
echo "0 3 * * * /usr/bin/certbot renew --quiet --webroot -w /var/www/certbot" > /etc/crontabs/root
crond -l 2

# Запускаем API в фоне
echo "🚀 Starting Node.js API"
cd /app && npm run start &

# Запускаем Nginx
echo "🚀 Starting Nginx"
exec nginx -g "daemon off;"
