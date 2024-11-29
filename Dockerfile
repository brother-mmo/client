# ---------- Базовый образ ----------
FROM node:22.11.0-alpine AS base

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# ---------- Этап разработки ----------
FROM base AS development

# Устанавливаем дополнительные зависимости для разработки (опционально)
# RUN npm install --only=dev

# Копируем весь код (исключая файлы из .dockerignore)
COPY . .

# Копируем файл .env для разработки
COPY .env .env

# Открываем порт для dev-сервера
EXPOSE 5173

# Команда для запуска dev-сервера
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ---------- Этап сборки ----------
FROM base AS build

# Устанавливаем переменную окружения для сборки
ENV NODE_ENV=production

# Копируем исходный код
COPY . .

# Копируем файл .env.production для сборки
COPY .env.production .env

# Сборка приложения
RUN npm run build

# ---------- Этап производства ----------
FROM nginx:alpine AS production

# Копируем сгенерированные файлы в nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Копируем конфигурацию nginx (опционально)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт 80
EXPOSE 80

# Команда для запуска nginx
CMD ["nginx", "-g", "daemon off;"]
