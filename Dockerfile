FROM node:18-alpine as build

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app/miniapp/src

# Копируем только package.json и package-lock.json (для оптимизации кэша)
COPY miniapp/src/package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем остальные файлы приложения
COPY miniapp/src .

# Собираем проект
RUN npm run build

# Финальный образ с Nginx
FROM nginx:alpine

# Копируем собранные файлы из стадии сборки
COPY --from=build /app/miniapp/src/dist /usr/share/nginx/html

# Открываем на порт 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
