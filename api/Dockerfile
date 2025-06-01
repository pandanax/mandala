FROM node:20.12.2-alpine AS api-builder
RUN apk update && apk upgrade
WORKDIR /app
COPY package*..json ./
COPY prisma ./prisma/
RUN npm install
RUN npx prisma generate  # Теперь будет работать
COPY . .
RUN npm run build

FROM nginx:alpine
RUN apk add --no-cache postgresql-client certbot certbot-nginx bash openssl nodejs npm && \
    mkdir -p /var/www/certbot && \
    mkdir -p /etc/letsencrypt/live && \
    chmod -R 755 /etc/letsencrypt && \
    rm /etc/nginx/conf.d/default.conf

WORKDIR /app
COPY --from=api-builder /app ./
RUN npm install --production

COPY ./nginx-api.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /docker-entrypoint.d/entrypoint.sh
RUN chmod +x /docker-entrypoint.d/entrypoint.sh

EXPOSE 80 443
