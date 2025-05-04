FROM node:20 AS build

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем только package.json и package-lock.json (для оптимизации кэша)
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем остальные файлы приложения
COPY . .

# Собираем проект
RUN npm run build

# Финальный образ с Nginx
FROM nginx:alpine

# Удаляем дефолтную конфигурацию
RUN rm /etc/nginx/conf.d/default.conf

# Копируем кастомную конфигурацию
COPY ./nginx.conf /etc/nginx/conf.d/

# Копируем собранные файлы из стадии сборки
COPY --from=build /app/dist /usr/share/nginx/html

# Открываем на порт 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
