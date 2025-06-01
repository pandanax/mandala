# Стадия сборки приложения
FROM node:20.12.2-alpine AS build

WORKDIR /app
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Базовый образ для production
FROM nginx:alpine

# Установка Certbot и зависимостей
RUN apk add --no-cache certbot certbot-nginx bash openssl && \
    mkdir -p /var/www/certbot && \
    rm /etc/nginx/conf.d/default.conf

# Копирование конфигов
COPY ./nginx.conf /etc/nginx/conf.d/
COPY --from=build /app/dist /usr/share/nginx/html

# Скрипт для инициализации и обновления сертификатов
COPY init-letsencrypt.sh /docker-entrypoint.d/

# Права на выполнение скриптов
RUN chmod +x /docker-entrypoint.d/init-letsencrypt.sh

# Открываем порты HTTP и HTTPS
EXPOSE 80
EXPOSE 443
