const express = require('express');
const mongoose = require('mongoose');
const app = express();

app.use(express.json());

// Conexión a MongoDB
mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/mi_basedatos', {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log('MongoDB conectado'))
    .catch(err => console.error('Error conectando a MongoDB:', err));

// Rutas
const usuarioRoutes = require('./routes/usuarios');
const grupoRoutes = require('./routes/grupos');

app.use('/usuarios', usuarioRoutes);
app.use('/grupos', grupoRoutes);

// Servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor escuchando en puerto ${PORT}`));
