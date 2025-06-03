# Stage 1: Build the application
FROM node:20.12.2-alpine AS api-builder

# Устанавливаем зависимости системы и очищаем кеш
RUN apk update && apk upgrade && \
    apk add --no-cache --virtual .build-deps git openssh-client && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# 1. Копируем только файлы зависимостей
COPY package.json package-lock.json ./

# 2. Устанавливаем зависимости (включая devDependencies для сборки)
RUN npm ci --no-optional

# 3. Копируем исходный код и Prisma схему
COPY . .
COPY prisma ./prisma/

# 4. Генерируем Prisma Client (уже не обязательно, так как делаем в CI)
# RUN npx prisma generate

# 5. Собираем production-версию приложения
RUN npm run build

# Stage 2: Production image
FROM nginx:alpine

# Устанавливаем только необходимые для production пакеты
RUN apk add --no-cache \
    postgresql-client \
    bash \
    openssl \
    nodejs=20.12.2-r0 \
    npm=10.2.4-r0 && \
    rm /etc/nginx/conf.d/default.conf && \
    mkdir -p /var/www/certbot && \
    mkdir -p /etc/letsencrypt/live && \
    chmod -R 755 /etc/letsencrypt

WORKDIR /app

# Копируем только необходимые файлы из builder-стадии
COPY --from=api-builder /app/package.json /app/package-lock.json ./
COPY --from=api-builder /app/node_modules ./node_modules
COPY --from=api-builder /app/dist ./dist
COPY --from=api-builder /app/prisma ./prisma

# Устанавливаем ТОЛЬКО production-зависимости (без devDependencies)
RUN npm ci --only=production --no-optional

# Копируем конфигурации
COPY ./nginx-api.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /docker-entrypoint.d/entrypoint.sh
RUN chmod +x /docker-entrypoint.d/entrypoint.sh

EXPOSE 80 443

# Указываем команду запуска через entrypoint
ENTRYPOINT ["/docker-entrypoint.d/entrypoint.sh"]
