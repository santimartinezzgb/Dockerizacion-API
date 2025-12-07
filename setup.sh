#!/bin/bash
set -e

# Cargar variables de entorno desde el archivo .env si existe
[ -f .env ] && export $(grep -v '^#' .env | xargs)

# Construir y levantar los servicios con Docker Compose
echo "Levantando servicios..."

# 2>/dev/null para evitar errores si no hay servicios corriendo
docker compose down 2>/dev/null || true 
docker compose up -d --build

# Esperar unos segundos para que los servicios se inicien correctamente
echo "Esperando servicios..."
sleep 5

# Mostrar mensaje de éxito
echo "API disponible en http://localhost:${PORT_API:-3000}"