FROM node:22-alpine

WORKDIR /app

# Установка Vite
RUN npm install -g npm@latest && \
    npm install -g typescript && \
    npm install -g create-vite

COPY . .
