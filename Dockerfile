FROM node:18-alpine as build

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app/miniapp/web

# Копируем только package.json и package-lock.json (для оптимизации кэша)
COPY miniapp/web/package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем остальные файлы приложения
COPY miniapp/web .

# Собираем проект
RUN npm run build

# Финальный образ с Nginx
FROM nginx:alpine

# Удаляем дефолтную конфигурацию
RUN rm /etc/nginx/conf.d/default.conf

# Копируем кастомную конфигурацию
COPY --from=build /app/miniapp/web/nginx.conf /etc/nginx/conf.d/

# Копируем собранные файлы из стадии сборки
COPY --from=build /app/miniapp/web/dist /usr/share/nginx/html

# Открываем на порт 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
