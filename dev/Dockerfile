FROM php:7.2-apache

# Enable mod_rewrite
RUN a2enmod rewrite

# Composer Version and SHA256 checksum
ENV COMPOSER_VERSION=1.10.10 \
    COMPOSER_SHA256=8f16aa77b1236ed40855d8d141c0a939d108a939c8e73f9f32eadd3f05f181b9

# Default environment variables
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEFAULT_TIMEZONE=Sweden/Stockholm \
    WEBROOT=/app/public

RUN apt-get -qq update

# Install Laravel requirements
RUN set -xe \
    && apt-get -qq -y install \
      libzip-dev \
      libicu-dev \
      libpq-dev \
      libxml2-dev \
      openssl \
      git \
      --no-install-recommends \
    && docker-php-ext-install \
      mbstring \
      tokenizer \
      xml \
      intl \
      pcntl \
    && true

# Install Opcache
RUN set -xe \
    && docker-php-ext-install \
      opcache \
    && true

# Install compression packages
RUN set -xe \
    && apt-get -qq -y install \
      zlib1g-dev \
      libbz2-dev \
      --no-install-recommends \
    && docker-php-ext-install \
      zip \
      bz2 \
    && true

# Install MySQL and PostgreSQL support
RUN set -xe \
    && docker-php-ext-configure \
      pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install \
      mysqli \
      pgsql \
      pdo_pgsql \
      pdo_mysql \
    && true

# Install Memcached and Redis
RUN set -xe \
    && apt-get -qq -y install \
      libmemcached-dev \
      --no-install-recommends \
    && pecl install \
      memcached-3.0.4 \
      redis-3.1.6 \
    && docker-php-ext-enable \
      memcached \
      redis \
    && true

# Install GD
RUN set -xe \
    && apt-get -qq -y install \
      libfontconfig1-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
    && docker-php-ext-configure \
      gd \
      --with-freetype-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
      -j$(nproc) gd \
    && true

# Install Debugging
RUN set -xe \
    && pecl install \
      xdebug-2.6.0 \
    && docker-php-ext-enable \
      xdebug \
    && true

# Install Vim
RUN set -xe \
    && apt-get -qq -y install \
      vim \
    && true

# Install Composer
RUN set -xe && \
    curl -sS -o /usr/local/bin/composer \
        -L https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar && \
    sha256sum /usr/local/bin/composer && \
    echo "$COMPOSER_SHA256 */usr/local/bin/composer" | sha256sum -c - && \
    chmod +x  /usr/local/bin/composer && \
    true

# Set up required folders for composer installation
RUN mkdir -p \
    /var/www/.composer/cache \
    /app/storage/framework/sessions \
    /app/storage/framework/views \
    /app/storage/framework/cache \
    /app/storage/logs

# Set up folder permissions
RUN chown -R www-data:www-data \
    /var/www/.composer/cache \
    /app \
    /var/www/

# Set directory for Laravel
WORKDIR /app

# Add WordPress rewrite to config
ADD laravel-rewrite.conf /etc/apache2/conf-available/laravel-rewrite.conf

# Configure PHP
RUN set -xe && \
    { \
        echo 'date.timezone = ${DEFAULT_TIMEZONE}'; \
    } > /usr/local/etc/php/conf.d/date-timezone.ini && \
    { \
        echo 'upload_max_filesize=50M'; \
        echo 'post_max_size=60M'; \
    } > /usr/local/etc/php/conf.d/upload-limit.ini && \
    true

# Configure Apache
RUN set -xe && \
    echo "DocumentRoot /app/public" >> /etc/apache2/apache2.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's#<Directory /var/www/>.*#<Directory /app/public/>#' /etc/apache2/apache2.conf && \
    ln -s /etc/apache2/conf-available/laravel-rewrite.conf /etc/apache2/conf-enabled/laravel-rewrite.conf && \
    true

# Clean up
RUN set -xe \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* \
    && true

# Add our entrypoint and make it executable
ADD run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

