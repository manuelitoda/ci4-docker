# Dockerfile para entorno de desarrollo CodeIgniter 4
FROM php:8.3-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd intl zip

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

# Configurar Git para evitar problemas de ownership
RUN git config --global --add safe.directory /var/www/html
RUN git config --global user.email "developer@localhost"
RUN git config --global user.name "Developer"

# Crear script de inicialización directamente
RUN echo '#!/bin/bash\n\n# Script de inicialización para el contenedor CodeIgniter 4\n# Se ejecuta cada vez que el contenedor inicia\n\nset -e\n\necho "🚀 Iniciando contenedor CodeIgniter 4..."\n\n# Asegurar que los directorios writable existen\nif [ ! -d "/var/www/html/writable" ]; then\n    mkdir -p /var/www/html/writable\nfi\n\necho "📁 Configurando permisos..."\n# Configurar permisos para el directorio writable\nchown -R www:www /var/www/html/writable/\nchmod -R 755 /var/www/html/writable/\n\n# Verificar si existe el directorio public y crear enlace simbólico si es necesario\nif [ ! -L "/var/www/html/public" ] && [ -d "/var/www/html/public" ]; then\n    echo "📂 Directorio public ya existe"\nelse\n    if [ ! -e "/var/www/html/public" ]; then\n        echo "🔗 Creando enlace simbólico para public"\n        ln -sf /var/www/html/public /var/www/html/public\n    fi\nfi\n\n# Configurar permisos generales\nchown -R www:www /var/www/html\nfind /var/www/html -type d -exec chmod 755 {} \\;\nfind /var/www/html -type f -exec chmod 644 {} \\;\n\n# Permisos especiales para writable\nchmod -R 777 /var/www/html/writable\n\necho "✅ Configuración completada. Iniciando Apache..."\n\n# Ejecutar Apache en primer plano\nexec apache2-foreground' > /usr/local/bin/docker-entrypoint.sh && chmod +x /usr/local/bin/docker-entrypoint.sh

# Exponer puerto 80
EXPOSE 80

# Comando por defecto
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]