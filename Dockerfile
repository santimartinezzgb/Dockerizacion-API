# ndica la imagen base para construir un contenedor.
# En este Dockerfile se utiliza la version 20, la cual incluye ya Node y npm instalados.
FROM node:20

# Establece el directorio de trabajo dentro del contenedor en /app.
# Todos los comandos que vienen a continuación se ejecutarán dentro de esta carpeta.
WORKDIR /app

# Copia los archivos package.json y package-lock.json desde el directorio del host al directorio del contenedor.
# Así se instalarán las dependencias necesarias en el contenedor.
COPY package*.json ./

# Ejecuta npm install dentro del contenedor para instalar las dependencias del proyecto,
# las cuales se pueden instalar gracias al paso anterior.
RUN npm install

# Copia todo el código del proyecto al directorio del contenedor
COPY . .

# Sugiere que el contenedor escuche el puerto 3000
EXPOSE 3000

# Comando que se va a ejecutar cuando se inicia el contenedor, iniciando así la aplicación
CMD ["npm", "start"]


