# Базовый образ
FROM node:20-alpine

# Установка зависимостей для Prisma, Certbot и SSL
RUN apk add --no-cache openssl certbot wget

# Скачиваем SSL сертификат для Yandex Cloud PostgreSQL
RUN mkdir -p /root/.postgresql && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /root/.postgresql/root.crt && \
    chmod 0600 /root/.postgresql/root.crt

# Рабочая директория
WORKDIR /app

# Копируем файлы зависимостей
COPY package*.json ./
COPY prisma ./prisma/

# Устанавливаем зависимости
RUN npm install

# Копируем остальные файлы приложения
COPY . .

# Генерируем Prisma Client
RUN npx prisma generate

# Создаем директорию для сертификатов
RUN mkdir -p /etc/letsencrypt/live/api.mandala-app.online

# Открываем порт
EXPOSE 3000

# Команда запуска
CMD ["sh", "-c", "npx prisma migrate deploy && node src/index.js"]
