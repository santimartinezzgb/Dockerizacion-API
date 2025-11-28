#!/bin/bash

# Nombres de contenedores
MONGO_CONTAINER="mongo"
API_CONTAINER="mi_api"
IMAGE_NAME="mi_api:v1.0.0"

# Variables de entorno de Mongo
MONGO_USER="root"
MONGO_PASSWORD="1234"
MONGO_DB="mi_basedatos"
API_PORT=3000
MONGO_PORT=27018

echo "Deteniendo y eliminando contenedores antiguos..."
docker stop $MONGO_CONTAINER $API_CONTAINER 2>/dev/null
docker rm $MONGO_CONTAINER $API_CONTAINER 2>/dev/null

echo "Construyendo imagen de la API..."
docker build -t $IMAGE_NAME .

echo "🗄️  Levantando MongoDB..."
docker run -d \
  --name $MONGO_CONTAINER \
  -e MONGO_INITDB_ROOT_USERNAME=$MONGO_USER \
  -e MONGO_INITDB_ROOT_PASSWORD=$MONGO_PASSWORD \
  -p $MONGO_PORT:27017 \
  mongo:6

# Esperar unos segundos para que Mongo arranque
echo "Esperando a que Mongo se inicialice..."
sleep 5

echo "Levantando la API conectada a Mongo..."
docker run -d \
  --name $API_CONTAINER \
  --link $MONGO_CONTAINER:mongo \
  -e MONGO_URI="mongodb://$MONGO_USER:$MONGO_PASSWORD@mongo:27017/$MONGO_DB?authSource=admin" \
  -e PORT=$API_PORT \
  -p $API_PORT:3000 \
  $IMAGE_NAME

# Esperar unos segundos para que la API arranque
echo "Esperando a que la API se inicialice..."
sleep 3

echo "Contenedores levantados. Probando la API con curl..."

echo "Ruta raíz:"
curl http://localhost:$API_PORT/
echo -e "\nCrear un grupo de prueba:"
curl -X POST http://localhost:$API_PORT/grupos \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Test","descripcion":"Grupo de prueba"}'
echo -e "\nListar grupos:"
curl http://localhost:$API_PORT/grupos
echo -e "\nTodo listo. La API está funcionando en http://localhost:$API_PORT"
