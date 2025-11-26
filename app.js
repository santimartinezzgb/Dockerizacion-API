const express = require('express');
const mongoose = require('mongoose');
const PORT = process.env.PORT || 3000;

// Instancia de express
const app = express();

// Middleware
app.use(express.json());

// Conexión a MongoDB
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('MongoDB conectado'))
    .catch(err => {
        console.error('Error conectando a MongoDB:', err);
        process.exit(1);
    });

// Rutas
const usuarioRoutes = require('./routes/usuarios');
const grupoRoutes = require('./routes/grupos');

// Uso de endpoints
app.use('/usuarios', usuarioRoutes);
app.use('/grupos', grupoRoutes);

// Conectar servidor
app.listen(PORT, () => console.log(`Servidor escuchando en puerto ${PORT}`));
