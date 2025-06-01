#!/bin/bash

# Start Node.js
echo "🚀 Starting Node.js API"
node /app/dist/index.js &

# Certbot setup
CERT_DIR="/etc/letsencrypt/live/api.mandala-app.online"

if [ ! -f "$CERT_DIR/fullchain.pem" ]; then
    echo "⚠️ Certificates missing! Initializing Certbot..."
    certbot certonly --non-interactive --agree-tos --webroot \
        --webroot-path /var/www/certbot \
        -d api.mandala-app.online \
        -d api.mandala-app.ru \
        --email sshishkintolik@mail.ru \
        --staging

    if [ ! -f "$CERT_DIR/fullchain.pem" ]; then
        echo "❌ Failed to generate certificates. Starting Nginx without HTTPS..."
        sed -i '/ssl_/d' /etc/nginx/conf.d/default.conf
        sed -i '/listen 443/d' /etc/nginx/conf.d/default.conf
    fi
fi

# Setup certbot renewal
echo "0 3 * * * /usr/bin/certbot renew --quiet --webroot -w /var/www/certbot" > /etc/crontabs/root
crond -l 2

# Start Nginx
echo "🚀 Starting Nginx"
exec nginx -g "daemon off;"
