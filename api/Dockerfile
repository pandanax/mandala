# Базовый образ
FROM node:20

# Установка зависимостей для Debian
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl \
    certbot \
    wget \
    bash \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# SSL сертификаты PostgreSQL
RUN mkdir -p /root/.postgresql && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /root/.postgresql/root.crt && \
    chmod 0600 /root/.postgresql/root.crt

# Рабочая директория
WORKDIR /app

# Копируем только package.json и prisma для кэширования
COPY package*.json ./
COPY prisma ./prisma/

# Установка зависимостей
RUN npm install

# Копируем остальные файлы
COPY . .

# Генерируем Prisma Client
RUN npx prisma generate && \
    chmod +x /app/init-ssl.sh && \
    mkdir -p /etc/letsencrypt/live/api.mandala-app.ru

# Порт и команда запуска
EXPOSE 3000
CMD ["sh", "-c", "/app/init-ssl.sh && npx prisma migrate deploy && node src/index.js"]

RUN apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
