# Базовый образ
FROM node:20.12.2-alpine AS api-builder
RUN apk update && apk upgrade

# Рабочая директория
WORKDIR /app

# Установка зависимостей
COPY package*.json ./
COPY prisma ./prisma/
RUN npm install
RUN npx prisma generate

# Копируем исходный код
COPY . .

# Сборка приложения
RUN npm run build

# Финальный образ с Nginx
FROM nginx:alpine

# Установка Certbot и зависимостей
RUN apk add --no-cache certbot certbot-nginx bash openssl && \
    mkdir -p /var/www/certbot && \
    rm /etc/nginx/conf.d/default.conf

# Копируем Nginx конфиг
COPY ./nginx-api.conf /etc/nginx/conf.d/default.conf

# Копируем собранное приложение
COPY --from=api-builder /app/dist /usr/share/nginx/html

# Копируем Prisma схему
COPY --from=api-builder /app/prisma ./prisma/

# Скрипт запуска
COPY start-api.sh /docker-entrypoint.d/start-api.sh
# Скрипт для инициализации и обновления сертификатов
COPY init-letsencrypt-api.sh /docker-entrypoint.d/

# Права на выполнение скриптов
RUN chmod +x /docker-entrypoint.d/start-api.sh
RUN chmod +x /docker-entrypoint.d/init-letsencrypt-api.sh

# Открываем порты
EXPOSE 80 443
