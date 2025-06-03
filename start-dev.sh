#!/bin/bash

# Останавливаем и удаляем все контейнеры
echo "🛑 Останавливаем и удаляем существующие контейнеры..."
podman-compose -f docker-compose-dev.yml down -v

# Пересобираем и запускаем контейнеры
echo "🔨 Пересобираем и запускаем контейнеры..."
podman-compose -f docker-compose-dev.yml up --build -d

# Ждем пока PostgreSQL будет готов принимать подключения
echo "⏳ Ожидаем готовности PostgreSQL..."
while ! podman-compose -f docker-compose-dev.yml exec postgres pg_isready -U user -d mandala; do
  sleep 2
done

# Применяем миграции Prisma
echo "🔄 Применяем миграции базы данных..."
podman-compose -f docker-compose-dev.yml exec api npx prisma migrate dev --name "dev_migration_$(date +%Y%m%d_%H%M%S)"

# Генерируем Prisma Client (на всякий случай)
echo "⚙️ Генерируем Prisma Client..."
podman-compose -f docker-compose-dev.yml exec api npx prisma generate

# Проверяем состояние миграций
echo "🔍 Проверяем состояние базы данных..."
podman-compose -f docker-compose-dev.yml exec api npx prisma migrate status

# Открываем браузер
echo "🌐 Открываем приложение в браузере..."
sleep 2  # Даем веб-серверу немного времени для запуска
open "http://localhost:5173/"

echo "✅ Готово! Приложение запущено и миграции применены."
