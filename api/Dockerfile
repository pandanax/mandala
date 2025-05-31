# Используем более свежий и безопасный базовый образ
FROM node:20

# Установка зависимостей с очисткой кеша
RUN apk add --no-cache --virtual .build-deps \
    openssl \
    certbot \
    wget \
    bash \
    && rm -rf /var/cache/apk/*

# SSL сертификаты PostgreSQL
RUN mkdir -p /root/.postgresql && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /root/.postgresql/root.crt && \
    chmod 0600 /root/.postgresql/root.crt

# Рабочая директория
WORKDIR /app

# Копируем только необходимые для установки зависимостей файлы
COPY package*.json ./
COPY prisma ./prisma/

# Установка зависимостей с аудитом безопасности
RUN npm install --production --audit --fund=false && \
    npm audit fix --force || true

# Копируем остальные файлы
COPY . .

# Генерируем Prisma Client
RUN npx prisma generate && \
    chmod +x /app/init-ssl.sh && \
    mkdir -p /etc/letsencrypt/live/api.mandala-app.ru

# Очистка временных файлов
RUN rm -rf /tmp/* && \
    apk del .build-deps

# Порт и команда запуска
EXPOSE 3000
CMD ["sh", "-c", "/app/init-ssl.sh && npx prisma migrate deploy && node src/index.js"]
