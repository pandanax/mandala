# Базовый образ
FROM node:20-alpine

# Установка зависимостей
RUN apk add --no-cache openssl certbot wget bash

# SSL сертификаты PostgreSQL
RUN mkdir -p /root/.postgresql && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /root/.postgresql/root.crt && \
    chmod 0600 /root/.postgresql/root.crt

# Рабочая директория
WORKDIR /app

# Копируем все необходимые файлы
COPY package*.json ./
COPY prisma ./prisma/
COPY init-ssl.sh ./
COPY . .

# Установка и сборка
RUN npm install && \
    npx prisma generate && \
    chmod +x /app/init-ssl.sh && \
    mkdir -p /etc/letsencrypt/live/api.mandala-app.ru

# Порт и команда запуска
EXPOSE 3000
CMD ["sh", "-c", "/app/init-ssl.sh && npx prisma migrate deploy && node src/index.js"]
