# Базовый образ
FROM node:20-alpine

# Установка зависимостей для Prisma
RUN apk add --no-cache openssl

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

# Открываем порт
EXPOSE 3000

# Команда запуска (применяем миграции и запускаем приложение)
CMD ["sh", "-c", "npx prisma migrate deploy && node index.js"]
