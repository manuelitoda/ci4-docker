#!/bin/bash

# Script de inicialización para el contenedor CodeIgniter 4
# Se ejecuta cada vez que el contenedor inicia

set -e

echo "🚀 Iniciando contenedor CodeIgniter 4..."

# Asegurar que los directorios writable existen
mkdir -p /var/www/html/writable/cache
mkdir -p /var/www/html/writable/logs
mkdir -p /var/www/html/writable/session
mkdir -p /var/www/html/writable/uploads
mkdir -p /var/www/html/writable/debugbar

# Configurar permisos correctos
echo "📁 Configurando permisos..."
chown -R www:www /var/www/html/writable/
chmod -R 777 /var/www/html/writable/

# Verificar que el directorio public existe
if [ ! -d "/var/www/html/public" ]; then
    echo "⚠️  Directorio public no encontrado. Creando enlace simbólico temporal..."
    ln -sf /var/www/html /var/www/html/public
fi

# Configurar permisos del usuario web
chown -R www:www /var/www/html
chmod -R 755 /var/www/html
chmod -R 777 /var/www/html/writable/

echo "✅ Permisos configurados correctamente"
echo "🌐 Iniciando Apache..."

# Ejecutar Apache en primer plano
exec apache2-foreground