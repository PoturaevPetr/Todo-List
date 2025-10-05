# Используем официальный образ Node для сборки
FROM node:22-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем весь проект
COPY . .

# Собираем Vue-приложение
RUN npm run build

# Создаем финальный образ для сервировки статических файлов
FROM nginx:stable-alpine

# Копируем собранные файлы из предыдущего этапа
COPY --from=builder /app/dist /usr/share/nginx/html

# Копируем конфигурационный файл nginx (если есть)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт 80
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]