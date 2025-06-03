# Stage 1: Build the application
FROM node:20.12.2-alpine AS api-builder

# Устанавливаем системные зависимости для сборки
RUN apk add --no-cache python3 make g++ git openssh-client

WORKDIR /app

# 1. Копируем файлы зависимостей
COPY package.json package-lock.json ./

# 2. Устанавливаем все зависимости (включая devDependencies)
RUN npm ci --no-optional

# 3. Копируем исходный код и Prisma схему
COPY . .
COPY prisma ./prisma/

# 4. Собираем приложение
RUN npm run build

# Stage 2: Production image
FROM nginx:alpine

# Устанавливаем только необходимые пакеты (используем доступные версии)
RUN apk add --no-cache \
    postgresql-client \
    bash \
    openssl \
    nodejs \
    npm && \
    rm /etc/nginx/conf.d/default.conf && \
    mkdir -p /var/www/certbot && \
    mkdir -p /etc/letsencrypt/live && \
    chmod -R 755 /etc/letsencrypt

WORKDIR /app

# Копируем только необходимое из builder-стадии
COPY --from=api-builder /app/package.json /app/package-lock.json ./
COPY --from=api-builder /app/node_modules ./node_modules
COPY --from=api-builder /app/dist ./dist
COPY --from=api-builder /app/prisma ./prisma

# Устанавливаем ТОЛЬКО production-зависимости
RUN npm ci --only=production --no-optional

# Копируем конфигурации
COPY ./nginx-api.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /docker-entrypoint.d/entrypoint.sh
RUN chmod +x /docker-entrypoint.d/entrypoint.sh

EXPOSE 80 443

# Используем кастомный entrypoint
ENTRYPOINT ["/docker-entrypoint.d/entrypoint.sh"]
