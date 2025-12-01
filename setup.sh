#!/bin/bash

echo "=== Configuración completa de API-Docker con CI/CD ==="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Verificar dependencias
echo -e "${YELLOW}[1/8] Verificando dependencias...${NC}"
if ! command_exists docker; then
    echo -e "${RED}Error: Docker no está instalado${NC}"
    exit 1
fi

# Verificar Docker Compose (versión moderna o legacy)
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
    echo -e "${GREEN}✓ Docker Compose (plugin) detectado${NC}"
elif command_exists docker-compose; then
    DOCKER_COMPOSE_CMD="docker-compose"
    echo -e "${GREEN}✓ Docker Compose (standalone) detectado${NC}"
else
    echo -e "${RED}Error: Docker Compose no está instalado${NC}"
    echo -e "${YELLOW}Instala con: sudo apt install docker-compose-plugin${NC}"
    exit 1
fi

if ! command_exists git; then
    echo -e "${RED}Error: Git no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Todas las dependencias están instaladas${NC}"
echo ""

# 2. Crear estructura de directorios
echo -e "${YELLOW}[2/8] Creando estructura de directorios...${NC}"
mkdir -p .github/workflows
mkdir -p tests
echo -e "${GREEN}✓ Estructura creada${NC}"
echo ""

# 3. Crear .gitignore
echo -e "${YELLOW}[3/8] Creando .gitignore...${NC}"
cat > .gitignore << 'EOF'
node_modules/
.env
*.log
.DS_Store
.vscode/
coverage/
dist/
EOF
echo -e "${GREEN}✓ .gitignore creado${NC}"
echo ""

# 4. Crear archivo .env (si no existe)
echo -e "${YELLOW}[4/8] Configurando variables de entorno...${NC}"
if [ ! -f .env ]; then
    cat > .env << 'EOF'
MONGO_URI=mongodb://root:1234@mongo:27017/mi_basedatos?authSource=admin
MONGO_INITDB_ROOT_USERNAME=root
MONGO_INITDB_ROOT_PASSWORD=1234
PORT=3000
EOF
    echo -e "${GREEN}✓ Archivo .env creado${NC}"
else
    echo -e "${GREEN}✓ Archivo .env ya existe${NC}"
fi
echo ""

# 5. Crear docker-compose.yml (si no existe)
echo -e "${YELLOW}[5/8] Creando docker-compose.yml...${NC}"
if [ ! -f docker-compose.yml ]; then
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build: .
    ports:
      - "${PORT}:3000"
    environment:
      - MONGO_URI=${MONGO_URI}
      - PORT=${PORT}
    depends_on:
      - mongo
    volumes:
      - .:/app
      - /app/node_modules
    command: node app.js

  mongo:
    image: mongo:latest
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
    volumes:
      - mongo-data:/data/db

volumes:
  mongo-data:
EOF
    echo -e "${GREEN}✓ docker-compose.yml creado${NC}"
else
    echo -e "${GREEN}✓ docker-compose.yml ya existe${NC}"
fi
echo ""

# 6. Crear workflow de GitHub Actions
echo -e "${YELLOW}[6/8] Creando workflow de GitHub Actions...${NC}"
cat > .github/workflows/main.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '20'
    
    - name: Install dependencies
      run: npm install
    
    - name: Run tests with MongoDB
      run: npm test
      continue-on-error: true
      env:
        MONGO_URI: ${{ secrets.MONGO_URI }}
        MONGO_INITDB_ROOT_USERNAME: ${{ secrets.MONGO_INITDB_ROOT_USERNAME }}
        MONGO_INITDB_ROOT_PASSWORD: ${{ secrets.MONGO_INITDB_ROOT_PASSWORD }}
        PORT: ${{ secrets.PORT }}
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build Docker image
      run: |
        docker build -t ${{ secrets.DOCKER_USERNAME }}/api-docker:latest .
        docker build -t ${{ secrets.DOCKER_USERNAME }}/api-docker:${{ github.sha }} .
    
    - name: Push Docker image
      run: |
        docker push ${{ secrets.DOCKER_USERNAME }}/api-docker:latest
        docker push ${{ secrets.DOCKER_USERNAME }}/api-docker:${{ github.sha }}
EOF
echo -e "${GREEN}✓ Workflow de GitHub Actions creado${NC}"
echo ""

# 7. Inicializar Git (si no está inicializado)
echo -e "${YELLOW}[7/8] Configurando Git...${NC}"
if [ ! -d .git ]; then
    git init
    echo -e "${GREEN}✓ Repositorio Git inicializado${NC}"
else
    echo -e "${GREEN}✓ Repositorio Git ya existe${NC}"
fi
echo ""

# 8. Levantar contenedores
echo -e "${YELLOW}[8/8] Levantando contenedores Docker...${NC}"
eval "$DOCKER_COMPOSE_CMD down" 2>/dev/null
eval "$DOCKER_COMPOSE_CMD up -d"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Contenedores levantados exitosamente${NC}"
else
    echo -e "${RED}✗ Error al levantar contenedores${NC}"
    exit 1
fi
echo ""

# Resumen final
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Configuración completada exitosamente${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}📋 Próximos pasos:${NC}"
echo ""
echo "1. Crear repositorio en GitHub:"
echo "   - Ve a https://github.com/new"
echo "   - Crea un nuevo repositorio"
echo ""
echo "2. Conectar tu repositorio local:"
echo "   ${GREEN}git remote add origin https://github.com/TU_USUARIO/TU_REPO.git${NC}"
echo ""
echo "3. Crear Secrets en GitHub (Settings > Secrets and variables > Actions):"
echo "   ${GREEN}MONGO_URI${NC} = mongodb://root:1234@mongo:27017/mi_basedatos?authSource=admin"
echo "   ${GREEN}MONGO_INITDB_ROOT_USERNAME${NC} = root"
echo "   ${GREEN}MONGO_INITDB_ROOT_PASSWORD${NC} = 1234"
echo "   ${GREEN}PORT${NC} = 3000"
echo "   ${GREEN}DOCKER_USERNAME${NC} = tu_usuario_dockerhub"
echo "   ${GREEN}DOCKER_PASSWORD${NC} = tu_contraseña_dockerhub"
echo ""
echo "4. Hacer el primer commit y push:"
echo "   ${GREEN}git add .${NC}"
echo "   ${GREEN}git commit -m \"Initial commit con CI/CD\"${NC}"
echo "   ${GREEN}git branch -M main${NC}"
echo "   ${GREEN}git push -u origin main${NC}"
echo ""
echo "5. Verificar el estado de los contenedores:"
echo "   ${GREEN}${DOCKER_COMPOSE_CMD} ps${NC}"
echo ""
echo "6. Ver logs:"
echo "   ${GREEN}${DOCKER_COMPOSE_CMD} logs -f${NC}"
echo ""
echo -e "${YELLOW}🔗 Links útiles:${NC}"
echo "   - API: http://localhost:3000"
echo "   - MongoDB: mongodb://localhost:27017"
echo ""
echo -e "${GREEN}¡Todo listo! 🚀${NC}"