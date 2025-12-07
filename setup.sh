#!/bin/bash
set -e
[ -f .env ] && export $(grep -v '^#' .env | xargs)

echo "Levantando servicios..."
docker compose down 2>/dev/null || true
docker compose up -d --build

echo "Esperando servicios..."
sleep 5

echo "API disponible en http://localhost:${PORT_API:-3000}"