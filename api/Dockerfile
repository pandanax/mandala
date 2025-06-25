# Stage 1: Build
FROM node:20.12.2-alpine AS api-builder

RUN apk add --no-cache python3 make g++ git openssh-client

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --no-optional

COPY . .
COPY prisma ./prisma/
RUN npm run build

# Stage 2: Production (на node:20-alpine, а не nginx:alpine!)
FROM node:20.12.2-alpine

RUN apk add --no-cache nginx postgresql-client bash openssl certbot
RUN mkdir -p /var/www/certbot /etc/letsencrypt/live/api.mandala-app.online/
RUN openssl req -x509 -nodes -days 3 -newkey rsa:2048 \
  -subj "/C=RU/ST=Moscow/L=Moscow/O=Test/CN=api.mandala-app.online" \
  -keyout /etc/letsencrypt/live/api.mandala-app.online/privkey.pem \
  -out /etc/letsencrypt/live/api.mandala-app.online/fullchain.pem

WORKDIR /app

# Копируем билд и модули из билдера
COPY --from=api-builder /app/package.json /app/package-lock.json ./
COPY --from=api-builder /app/node_modules ./node_modules
COPY --from=api-builder /app/dist ./dist
COPY --from=api-builder /app/prisma ./prisma

RUN npm ci --only=production --no-optional

# Nginx config и энтрипойнт
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx-api.conf /etc/nginx/conf.d/api.conf
COPY nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /docker-entrypoint.d/entrypoint.sh
RUN chmod +x /docker-entrypoint.d/entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.d/entrypoint.sh"]
