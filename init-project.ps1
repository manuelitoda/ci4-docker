# Script de inicialización para el entorno de desarrollo CodeIgniter 4
# Autor: Asistente AI
# Descripción: Automatiza la configuración inicial del proyecto (Windows PowerShell)

# Configurar política de ejecución si es necesario
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Write-Host "🚀 Iniciando configuración del entorno de desarrollo CodeIgniter 4..." -ForegroundColor Blue

# Función para mostrar mensajes con colores
function Show-Message {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Show-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Show-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Show-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Verificar si Docker está instalado
try {
    docker --version | Out-Null
    Show-Success "Docker está instalado."
} catch {
    Show-Error "Docker no está instalado. Por favor, instala Docker Desktop."
    exit 1
}

# Verificar si Docker Compose está instalado
try {
    docker-compose --version | Out-Null
    Show-Success "Docker Compose está instalado."
} catch {
    Show-Error "Docker Compose no está instalado. Por favor, instala Docker Compose."
    exit 1
}

# Crear directorio de logs si no existe
if (!(Test-Path "logs")) {
    New-Item -ItemType Directory -Name "logs" | Out-Null
    Show-Message "Directorio 'logs' creado."
}

# Crear directorio mysql-init si no existe
if (!(Test-Path "mysql-init")) {
    New-Item -ItemType Directory -Name "mysql-init" | Out-Null
    Show-Message "Directorio 'mysql-init' creado."
}

# Construir e iniciar contenedores
Show-Message "Construyendo e iniciando contenedores..."
try {
    docker-compose -f docker/docker-compose.yml up -d --build
    Show-Success "Contenedores iniciados correctamente."
} catch {
    Show-Error "Error al iniciar los contenedores."
    exit 1
}

# Esperar a que los servicios estén listos
Show-Message "Esperando a que los servicios estén listos..."
Start-Sleep -Seconds 30

# Verificar si CodeIgniter 4 ya está instalado
if (!(Test-Path "app\Config\App.php")) {
    Show-Message "Instalando CodeIgniter 4..."
    
    try {
        # Instalar CodeIgniter 4
        docker-compose -f docker/docker-compose.yml exec -T web composer create-project codeigniter4/appstarter . --no-dev
        
        # Copiar archivo de configuración
        if (Test-Path ".env.example") {
            docker-compose -f docker/docker-compose.yml exec -T web cp .env.example .env
            Show-Message "Archivo .env creado desde .env.example"
        }
        
        # Configurar permisos
        docker-compose -f docker/docker-compose.yml exec -T web chown -R www:www /var/www/html
        docker-compose -f docker/docker-compose.yml exec -T web chmod -R 755 /var/www/html
        docker-compose -f docker/docker-compose.yml exec -T web chmod -R 777 writable/
        
        Show-Success "CodeIgniter 4 instalado correctamente."
    } catch {
        Show-Error "Error durante la instalación de CodeIgniter 4."
        Show-Warning "Puedes instalarlo manualmente ejecutando:"
        Write-Host "docker-compose -f docker/docker-compose.yml exec web composer create-project codeigniter4/appstarter . --no-dev" -ForegroundColor Gray
    }
} else {
    Show-Warning "CodeIgniter 4 ya está instalado."
}

# Mostrar información de servicios
Write-Host ""
Show-Success "🎉 ¡Entorno de desarrollo configurado correctamente!"
Write-Host ""
Write-Host "📋 Servicios disponibles:" -ForegroundColor White
Write-Host "   🌐 Aplicación Web: http://localhost:8080" -ForegroundColor White
Write-Host "   🗄️  phpMyAdmin: http://localhost:8081" -ForegroundColor White
Write-Host "   🐬 MySQL: localhost:3306" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Credenciales de base de datos:" -ForegroundColor White
Write-Host "   📊 Base de datos: ci4_database" -ForegroundColor White
Write-Host "   👤 Usuario: ci4_user" -ForegroundColor White
Write-Host "   🔒 Contraseña: ci4_password" -ForegroundColor White
Write-Host "   👑 Root: root / root_password" -ForegroundColor White
Write-Host ""
Write-Host "🛠️  Comandos útiles:" -ForegroundColor White
Write-Host "   docker-compose -f docker/docker-compose.yml logs -f          # Ver logs" -ForegroundColor Gray
Write-Host "   docker-compose -f docker/docker-compose.yml exec web bash   # Acceder al contenedor" -ForegroundColor Gray
Write-Host "   docker-compose -f docker/docker-compose.yml down            # Detener servicios" -ForegroundColor Gray
Write-Host ""
Show-Success "¡Listo para desarrollar! 🚀"

# Preguntar si desea abrir el navegador
$openBrowser = Read-Host "¿Deseas abrir la aplicación en el navegador? (s/n)"
if ($openBrowser -eq "s" -or $openBrowser -eq "S" -or $openBrowser -eq "y" -or $openBrowser -eq "Y") {
    Start-Process "http://localhost:8080"
    Show-Message "Abriendo aplicación en el navegador..."
}

Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")