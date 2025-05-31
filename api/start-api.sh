#!/bin/bash

# Запускаем Node.js приложение в фоне
node /usr/share/nginx/html/index.js &

# Запускаем Nginx
exec nginx -g "daemon off;"
