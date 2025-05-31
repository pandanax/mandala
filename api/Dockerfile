# Базовый образ для сборки
FROM node:20.12.2-alpine AS builder

WORKDIR /app
COPY package*.json ./
COPY prisma ./prisma/
RUN npm ci && npx prisma generate
COPY . .
RUN npm run build

# Финальный образ
FROM node:20.12.2-alpine

WORKDIR /app
ENV NODE_ENV=production

# Копируем только необходимое
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# Создаем непривилегированного пользователя
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser && \
    chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000
CMD ["node", "dist/index.js"]
