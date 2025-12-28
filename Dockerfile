# ---- Base: PHP 8.3 + Apache ----
# Pawtucket2 ist das öffentliche Frontend und benötigt PHP + ähnliche Extensions.
# Offizielles Repo: https://github.com/collectiveaccess/pawtucket2
FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    libjpeg62-turbo-dev libpng-dev libfreetype6-dev \
    libzip-dev libonig-dev libxml2-dev libicu-dev \
    unzip git curl nano \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install pdo pdo_mysql gd mbstring zip intl exif

RUN a2enmod rewrite \
 && sed -ri 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Composer installieren
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Pawtucket2-Code
COPY . /var/www/html
WORKDIR /var/www/html

# Dependencies installieren
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader || true

# setup.php bereitstellen (Repo liefert setup.php-dist)
RUN if [ -f "/var/www/html/setup.php-dist" ] && [ ! -f "/var/www/html/setup.php" ]; then \
      cp /var/www/html/setup.php-dist /var/www/html/setup.php; \
    fi

# Medienlink auf Providence: Symlink, damit Pawtucket die gleichen Medien nutzt.
# Pfad /pawtucket/media/collectiveaccess -> /providence/media/collectiveaccess
# In Render-Prod kannst du das über persistente Volumes/Env konfigurieren.
# Community-Doku zum gemeinsamen Medienordner:
# https://imaginingfutures.github.io/if-documentation/content/developers/replicate/3-install.html
RUN mkdir -p /var/www/html/media \
 && ln -s /var/www/html/media/collectiveaccess /var/www/html/media/collectiveaccess || true

# PHP-Limits optional anheben (Frontend zeigt große Medien an)
RUN { \
      echo "upload_max_filesize=64M"; \
      echo "post_max_size=64M"; \
      echo "memory_limit=256M"; \
    } > /usr/local/etc/php/conf.d/ca.ini

COPY docker/entrypoint-pawtucket.sh /usr/local/bin/entrypoint-pawtucket.sh
RUN chmod +x /usr/local/bin/entrypoint-pawtucket.sh

EXPOSE 80
CMD ["/usr/local/bin/entrypoint-pawtucket.sh"]
