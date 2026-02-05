FROM php:8.2-cli-alpine

WORKDIR /app

RUN apk add --no-cache \
    curl \
    && docker-php-ext-install pdo pdo_mysql

COPY . .

CMD ["php", "src/index.php"]
