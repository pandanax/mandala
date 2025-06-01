#!/bin/bash

# Инициализация БД
init_db() {
    local max_retries=5
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if psql "$DB_URL" -c "CREATE SCHEMA IF NOT EXISTS mandala_app; GRANT ALL ON SCHEMA mandala_app TO mandala_user;" &>/dev/null; then
            echo "✅ Database schema initialized"
            return 0
        fi
        echo "⚠️ Failed to initialize database (attempt $((retry+1))/$max_retries)"
        sleep 5
        ((retry++))
    done
    return 1
}

# Применение миграций
apply_migrations() {
    cd /app
    if ! npx prisma migrate deploy; then
        echo "❌ Failed to apply migrations"
        return 1
    fi
    return 0
}

# Основной процесс
if ! init_db || ! apply_migrations; then
    echo "🛑 Failed to initialize database, exiting..."
    exit 1
fi

# Запуск приложения
echo "🚀 Starting Node.js API"
node dist/index.js &

# Настройка Certbot
CERT_DIR="/etc/letsencrypt/live/api.mandala-app.online"
if [ ! -f "$CERT_DIR/fullchain.pem" ]; then
    echo "⚠️ Initializing Certbot..."
    certbot certonly --non-interactive --agree-tos --webroot \
        --webroot-path /var/www/certbot \
        -d api.mandala-app.online \
        -d api.mandala-app.ru \
        --email sshishkintolik@mail.ru \
        --staging || echo "⚠️ Certbot initialization failed"
fi

# Настройка cron для обновления сертификатов
echo "0 3 * * * /usr/bin/certbot renew --quiet --webroot -w /var/www/certbot" > /etc/crontabs/root
crond -l 2

echo "🚀 Starting Nginx"
exec nginx -g "daemon off;"
exec > >(tee -a /var/log/startup.log) 2>&1
