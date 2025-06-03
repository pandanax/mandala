#!/bin/bash
set -e

# Функция для инициализации схемы БД
init_db() {
    local max_retries=5
    local retry=0

    while [ $retry -lt $max_retries ]; do
        # Проверяем доступ к схеме через простой запрос
        if psql "$DB_URL" -c "SELECT 1 FROM pg_namespace WHERE nspname = 'mandala_app'" | grep -q 1; then
            echo "✅ Database schema exists"
            return 0
        else
            echo "⚠️ Schema 'mandala_app' not found, attempting to create..."
            if psql "$DB_URL" -c "CREATE SCHEMA IF NOT EXISTS mandala_app;
                GRANT USAGE ON SCHEMA mandala_app TO mandala_user;
                GRANT CREATE ON SCHEMA mandala_app TO mandala_user;" &>/dev/null; then
                echo "✅ Database schema initialized"
                return 0
            fi
        fi

        echo "⚠️ Failed to initialize database (attempt $((retry+1))/$max_retries)"
        sleep 5
        ((retry++))
    done
    return 1
}

# Функция для генерации Prisma Client
generate_prisma_client() {
    echo "Generating Prisma Client..."
    cd /app
    npx prisma generate
}

# Функция для применения миграций
apply_migrations() {
    echo "Applying database migrations..."
    cd /app
    npx prisma migrate deploy
}

# Основной процесс
if ! init_db || ! generate_prisma_client || ! apply_migrations; then
    echo "🛑 Database initialization failed, exiting..."
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
