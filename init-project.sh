#!/bin/bash

# Script de inicialización para el entorno de desarrollo CodeIgniter 4
# Autor: Asistente AI
# Descripción: Automatiza la configuración inicial del proyecto

set -e

echo "🚀 Iniciando configuración del entorno de desarrollo CodeIgniter 4..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
show_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

show_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

show_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

show_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    show_error "Docker no está instalado. Por favor, instala Docker Desktop."
    exit 1
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    show_error "Docker Compose no está instalado. Por favor, instala Docker Compose."
    exit 1
fi

show_success "Docker y Docker Compose están instalados."

# Crear directorio de logs si no existe
if [ ! -d "logs" ]; then
    mkdir logs
    show_message "Directorio 'logs' creado."
fi

# Crear directorio mysql-init si no existe
if [ ! -d "mysql-init" ]; then
    mkdir mysql-init
    show_message "Directorio 'mysql-init' creado."
fi

# Construir e iniciar contenedores
show_message "Construyendo e iniciando contenedores..."
docker-compose -f docker/docker-compose.yml up -d --build

# Esperar a que los servicios estén listos
show_message "Esperando a que los servicios estén listos..."
sleep 30

# Verificar si CodeIgniter 4 ya está instalado
if [ ! -f "app/Config/App.php" ]; then
    show_message "Instalando CodeIgniter 4..."
    
    # Instalar CodeIgniter 4
    docker-compose -f docker/docker-compose.yml exec -T web composer create-project codeigniter4/appstarter . --no-dev
    
    # Copiar archivo de configuración
    if [ -f ".env.example" ]; then
        docker-compose -f docker/docker-compose.yml exec -T web cp .env.example .env
        show_message "Archivo .env creado desde .env.example"
    fi
    
    # Configurar permisos
    docker-compose -f docker/docker-compose.yml exec -T web chown -R www:www /var/www/html
    docker-compose -f docker/docker-compose.yml exec -T web chmod -R 755 /var/www/html
    docker-compose -f docker/docker-compose.yml exec -T web chmod -R 777 writable/
    
    show_success "CodeIgniter 4 instalado correctamente."
else
    show_warning "CodeIgniter 4 ya está instalado."
fi

# Mostrar información de servicios
echo ""
show_success "🎉 ¡Entorno de desarrollo configurado correctamente!"
echo ""
echo "📋 Servicios disponibles:"
echo "   🌐 Aplicación Web: http://localhost:8080"
echo "   🗄️  phpMyAdmin: http://localhost:8081"
echo "   🐬 MySQL: localhost:3306"
echo ""
echo "🔑 Credenciales de base de datos:"
echo "   📊 Base de datos: ci4_database"
echo "   👤 Usuario: ci4_user"
echo "   🔒 Contraseña: ci4_password"
echo "   👑 Root: root / root_password"
echo ""
echo "🛠️  Comandos útiles:"
echo "   docker-compose -f docker/docker-compose.yml logs -f          # Ver logs"
echo "   docker-compose -f docker/docker-compose.yml exec web bash   # Acceder al contenedor"
echo "   docker-compose -f docker/docker-compose.yml down            # Detener servicios"
echo ""
show_success "¡Listo para desarrollar! 🚀"