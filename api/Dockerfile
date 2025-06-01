FROM node:20.12.2-alpine AS api-builder
RUN apk update && apk upgrade
WORKDIR /app
COPY package*.json ./
COPY prisma ./prisma/
RUN npm install
RUN npx prisma generate
COPY . .
RUN npm run build

FROM nginx:alpine
RUN apk add --no-cache certbot certbot-nginx bash openssl && \
    mkdir -p /var/www/certbot && \
    mkdir -p /etc/letsencrypt/live && \
    chmod -R 755 /etc/letsencrypt && \
    rm /etc/nginx/conf.d/default.conf

# Копируем конфиги
COPY ./nginx-api.conf /etc/nginx/conf.d/default.conf
# Копируем ВСЁ приложение из builder-стадии
COPY --from=api-builder /app /app

# И только статику в nginx
COPY --from=api-builder /app/dist /usr/share/nginx/html
COPY --from=api-builder /app/prisma ./prisma/

# Копируем скрипт запуска
COPY entrypoint.sh /docker-entrypoint.d/entrypoint.sh
RUN chmod +x /docker-entrypoint.d/entrypoint.sh

EXPOSE 80 443
