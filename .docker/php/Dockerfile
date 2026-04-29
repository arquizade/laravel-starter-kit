FROM php:8.5-rc-fpm

# System dependencies + Playwright/Chromium system libs
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype-dev \
    libpq-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    supervisor \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxshmfence1 \
    libcairo2 \
    libpango-1.0-0 \
    fonts-liberation \
    xdg-utils \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 (required by pest-plugin-browser)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure gd separately first
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install extensions one at a time to avoid parallel build issues on PHP 8.5-rc
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif
RUN docker-php-ext-install gd
RUN docker-php-ext-install intl
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install sockets
RUN docker-php-ext-install xml
RUN docker-php-ext-install zip

# Redis extension via PECL
RUN pecl install redis && docker-php-ext-enable redis

# Xdebug — installed but controlled via XDEBUG_MODE env var
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Ensure npm/node are on PATH at runtime for all users
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Non-root user matching typical host UID
RUN groupadd -g 1000 laravel \
    && useradd -u 1000 -g laravel -m -d /home/laravel laravel \
    && mkdir -p /home/laravel/.cache \
    && chown -R laravel:laravel /home/laravel

# Install playwright package and Chromium as root at build time
# This avoids memory pressure and permission issues at runtime.
# PLAYWRIGHT_BROWSERS_PATH makes the browser available to all users.
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/local/ms-playwright
RUN npm install -g playwright \
    && npx playwright install chromium \
    && chmod -R 755 /usr/local/ms-playwright

USER laravel

EXPOSE 9000

CMD ["php-fpm"]
