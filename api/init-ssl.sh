#!/bin/bash

if [ ! -f "/etc/letsencrypt/live/api.mandala-app.online/fullchain.pem" ]; then
  echo "Initializing Certbot..."
  certbot certonly --non-interactive --agree-tos --standalone \
    -d api.mandala-app.online \
    -d api.mandala-app.ru \
    --email sshishkintolik@mail.ru \
    --preferred-challenges http
fi

ln -sf /etc/letsencrypt/live/api.mandala-app.online /etc/letsencrypt/live/api.mandala-app.ru || true

echo "0 3 * * * certbot renew --quiet --standalone --post-hook 'pkill -SIGHUP node'" > /etc/crontabs/root
crond
