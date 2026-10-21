FROM php:8.1-cli
RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev libsqlite3-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install pdo_sqlite pdo_mysql zip gd mbstring bcmath
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_NO_SECURITY_BLOCKING=1
WORKDIR /app
COPY . .
RUN composer install --no-dev --ignore-platform-reqs --no-interaction \
 && cp -n .env.example .env && touch database/database.sqlite \
 && chmod -R 777 storage bootstrap/cache database
ENV APP_ENV=production APP_DEBUG=false DB_CONNECTION=sqlite DB_DATABASE=/app/database/database.sqlite
CMD sh -c "php artisan config:clear && php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"
