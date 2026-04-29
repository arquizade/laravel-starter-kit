FROM php:8.3-fpm

# System dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions required by Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        exif \
        gd \
        intl \
        mbstring \
        opcache \
        pcntl \
        pdo \
        pdo_pgsql \
        pgsql \
        xml \
        zip

# Redis extension via PECL
RUN pecl install redis && docker-php-ext-enable redis

# Xdebug — installed but controlled via XDEBUG_MODE env var
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Non-root user matching typical host UID
RUN groupadd -g 1000 laravel && useradd -u 1000 -g laravel -m laravel

USER laravel

EXPOSE 9000

CMD ["php-fpm"]
