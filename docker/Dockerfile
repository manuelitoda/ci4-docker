# Dockerfile para entorno de desarrollo CodeIgniter 4
FROM php:8.3-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar Apache
RUN a2enmod rewrite
RUN a2enmod headers

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar configuración personalizada de Apache
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf
COPY apache-security.conf /etc/apache2/conf-available/security.conf

# Habilitar configuración de seguridad
RUN a2enconf security

# Crear usuario para desarrollo
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Cambiar propietario del directorio web
RUN chown -R www:www /var/www/html
RUN chmod -R 755 /var/www/html

# Asegurar permisos de escritura para CodeIgniter
RUN mkdir -p /var/www/html/writable/cache /var/www/html/writable/logs /var/www/html/writable/session /var/www/html/writable/uploads
RUN chmod -R 777 /var/www/html/writable/
RUN chown -R www:www /var/www/html/writable/

# Configurar PHP
COPY ./php.ini /usr/local/etc/php/

# Copiar script de inicialización
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exponer puerto 80
EXPOSE 80

# Comando por defecto
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]