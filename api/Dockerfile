# Базовый образ
FROM node:20-alpine AS api-builder

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

# Установка зависимостей
RUN apk add --no-cache bash openssl

# Копируем Nginx конфиг
COPY ./nginx-api.conf /etc/nginx/conf.d/default.conf

# Копируем собранное приложение
COPY --from=api-builder /app/dist /usr/share/nginx/html

# Копируем Prisma схему
COPY --from=api-builder /app/prisma ./prisma/

# Скрипт запуска
COPY start-api.sh /docker-entrypoint.d/start-api.sh
RUN chmod +x /docker-entrypoint.d/start-api.sh

# Открываем порты
EXPOSE 80 443
