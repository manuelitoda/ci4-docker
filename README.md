# Entorno de Desarrollo CodeIgniter 4 con Docker

Este proyecto proporciona un entorno de desarrollo completo para CodeIgniter 4 utilizando Docker y Docker Compose.

## Características

- **PHP 8.3** con Apache
- **MySQL 8.0** como base de datos
- **phpMyAdmin** para administración de base de datos
- **Composer** preinstalado
- Configuración optimizada para desarrollo
- Extensiones PHP necesarias para CodeIgniter 4

## Requisitos Previos

- Docker Desktop instalado
- Docker Compose instalado
- Git (opcional, para clonar proyectos)

## Estructura del Proyecto

```
ci4-docker/
├── docker/                 # Archivos de configuración Docker
│   ├── Dockerfile          # Configuración del contenedor web
│   ├── docker-compose.yml  # Orquestación de servicios
│   ├── apache-config.conf  # Configuración de Apache VirtualHost
│   ├── apache-security.conf # Configuración de seguridad de Apache
│   ├── docker-entrypoint.sh # Script de inicialización del contenedor
│   └── php.ini             # Configuración de PHP
├── .env.example           # Variables de entorno de ejemplo
├── init-project.sh        # Script de inicialización (Linux/macOS)
├── init-project.ps1       # Script de inicialización (Windows)
├── README.md              # Este archivo
└── logs/                  # Logs de Apache (se crea automáticamente)
```

## Instalación y Uso

### Opción 1: Instalación Automática (Recomendada)

#### En Windows:
```powershell
# Ejecutar el script de PowerShell
.\init-project.ps1
```

#### En Linux/macOS:
```bash
# Dar permisos de ejecución y ejecutar
chmod +x init-project.sh
./init-project.sh
```

Los scripts automatizan todo el proceso: crean directorios, construyen contenedores, instalan CodeIgniter 4 y configuran permisos.

### Opción 2: Instalación Manual

#### 1. Preparar el entorno

```bash
# Clonar o descargar este repositorio
git clone <tu-repositorio>
cd ci4-docker

# Crear directorio para logs
mkdir logs
```

#### 2. Instalar CodeIgniter 4

```bash
# Construir e iniciar los contenedores
docker-compose -f docker/docker-compose.yml up -d

# Acceder al contenedor web
docker-compose -f docker/docker-compose.yml exec web bash

# Instalar CodeIgniter 4 usando Composer
composer create-project codeigniter4/appstarter . --no-dev

# Copiar archivo de configuración
cp .env.example .env

# Configurar permisos
chmod -R 777 writable/
```

### 3. Configurar la base de datos

Edita el archivo `.env` y asegúrate de que las configuraciones de base de datos coincidan:

```env
CI_ENVIRONMENT = development

app.baseURL = 'http://localhost:8080/'

database.default.hostname = database
database.default.database = ci4_database
database.default.username = ci4_user
database.default.password = ci4_password
database.default.DBDriver = MySQLi
database.default.port = 3306
```

## Servicios Disponibles

| Servicio | URL | Descripción |
|----------|-----|-------------|
| Aplicación Web | http://localhost:8080 | Tu aplicación CodeIgniter 4 |
| phpMyAdmin | http://localhost:8081 | Administrador de base de datos |
| MySQL | localhost:3306 | Base de datos (acceso directo) |

## Credenciales de Base de Datos

- **Host:** database (desde la aplicación) / localhost (desde tu máquina)
- **Puerto:** 3306
- **Base de datos:** ci4_database
- **Usuario:** ci4_user
- **Contraseña:** ci4_password
- **Usuario root:** root
- **Contraseña root:** root_password

## Comandos Útiles

### Gestión de contenedores

```bash
# Iniciar servicios
docker-compose -f docker/docker-compose.yml up -d

# Detener servicios
docker-compose -f docker/docker-compose.yml down

# Ver logs
docker-compose -f docker/docker-compose.yml logs -f

# Acceder al contenedor web
docker-compose -f docker/docker-compose.yml exec web bash

# Acceder al contenedor de MySQL
docker-compose -f docker/docker-compose.yml exec database mysql -u root -p
```

### Desarrollo

```bash
# Instalar dependencias
docker-compose -f docker/docker-compose.yml exec web composer install

# Actualizar dependencias
docker-compose -f docker/docker-compose.yml exec web composer update

# Ejecutar migraciones
docker-compose -f docker/docker-compose.yml exec web php spark migrate

# Crear controlador
docker-compose -f docker/docker-compose.yml exec web php spark make:controller NombreControlador

# Crear modelo
docker-compose -f docker/docker-compose.yml exec web php spark make:model NombreModelo
```

## Estructura de Archivos CodeIgniter 4

Una vez instalado CodeIgniter 4, tendrás la siguiente estructura:

```
├── app/                   # Código de la aplicación
│   ├── Controllers/       # Controladores
│   ├── Models/           # Modelos
│   ├── Views/            # Vistas
│   └── Config/           # Configuraciones
├── public/               # Archivos públicos (DocumentRoot)
│   ├── index.php         # Punto de entrada
│   └── assets/           # CSS, JS, imágenes
├── writable/             # Archivos escribibles (logs, cache)
└── vendor/               # Dependencias de Composer
```

## Solución de Problemas

### Error de permisos

Los permisos se configuran automáticamente al iniciar el contenedor mediante el script `docker-entrypoint.sh`. Si experimentas problemas de permisos:

```bash
# Reiniciar el contenedor para aplicar permisos
docker-compose -f docker/docker-compose.yml restart web

# O manualmente desde el contenedor
docker-compose -f docker/docker-compose.yml exec web chown -R www:www /var/www/html
docker-compose -f docker/docker-compose.yml exec web chmod -R 777 /var/www/html/writable/
```

### Error de cache

Si ves el error "Cache unable to write to '/var/www/html/writable/cache/'":

```bash
# El script de inicialización debería resolverlo automáticamente
docker-compose -f docker/docker-compose.yml restart web

# Verificar permisos
docker-compose -f docker/docker-compose.yml exec web ls -la /var/www/html/writable/
```

### Reiniciar servicios

```bash
# Reiniciar todos los servicios
docker-compose -f docker/docker-compose.yml restart

# Reiniciar solo el servicio web
docker-compose -f docker/docker-compose.yml restart web
```

### Limpiar y reconstruir

```bash
# Detener y eliminar contenedores
docker-compose -f docker/docker-compose.yml down

# Eliminar imágenes
docker-compose -f docker/docker-compose.yml down --rmi all

# Reconstruir
docker-compose -f docker/docker-compose.yml build --no-cache
docker-compose -f docker/docker-compose.yml up -d
```

## Personalización

### Cambiar versión de PHP

Edita el `docker/Dockerfile` y cambia la primera línea:

```dockerfile
FROM php:8.2-apache  # Para PHP 8.2
FROM php:8.1-apache  # Para PHP 8.1
```

### Agregar extensiones PHP

Edita el `docker/Dockerfile` y agrega las extensiones en la sección `RUN docker-php-ext-install`:

```dockerfile
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip redis
```

### Configurar SSL

Para habilitar HTTPS, modifica el `docker/apache-config.conf` y agrega certificados SSL.

## Contribuir

Si encuentras algún problema o tienes sugerencias de mejora, por favor:

1. Crea un issue
2. Envía un pull request
3. Comparte tu experiencia

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.