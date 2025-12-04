#!/bin/bash
set -e

# Variables
VERSION=$(grep -Po '(?<="version": ")[^"]*' package.json)
IMAGE="${DOCKER_USERNAME:-local}/api-docker:v${VERSION}"

echo "Iniciando setup..."

# Construir imagen
echo "Construyendo imagen: $IMAGE"
docker build -t $IMAGE .
docker tag $IMAGE ${DOCKER_USERNAME:-local}/api-docker:latest

# Levantar con docker-compose
echo "Levantando servicios..."
docker-compose down 2>/dev/null || true
docker-compose up -d

# Esperar a que Mongo esté listo
echo "Esperando MongoDB..."
until docker exec mongo mongosh --eval "db.adminCommand('ping')" --quiet > /dev/null 2>&1; do
    printf '.'
    sleep 2
done
echo "Listo"

# Esperar a que la API esté lista
echo "Esperando API..."
sleep 3
for i in {1..10}; do
    if curl -s http://localhost:3000/ > /dev/null 2>&1; then
        echo "Listo"
        break
    fi
    printf '.'
    sleep 1
done

# Probar API
echo "Probando API..."
curl -s http://localhost:3000/
echo -e "\n"
curl -s -X POST http://localhost:3000/grupos -H "Content-Type: application/json" -d '{"nombre":"Test","descripcion":"Prueba"}'
echo -e "\n"

# Subir a Docker Hub si hay credenciales
if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
    echo "Subiendo a Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    docker push $IMAGE
    docker push ${DOCKER_USERNAME}/api-docker:latest
    echo "Imagen en Docker Hub: $IMAGE"
fi

echo -e "\nTodo funcionando. API en http://localhost:3000"