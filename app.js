// app.js
const express = require('express');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Conexión a MongoDB
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('MongoDB conectado'))
    .catch(err => {
        console.error('Error conectando a MongoDB:', err);
        process.exit(1);
    });

// Modelo simple de grupo
const grupoSchema = new mongoose.Schema({
    nombre: String,
    descripcion: String,
});
const Grupo = mongoose.model('Grupo', grupoSchema);

// Rutas
app.get('/', (req, res) => res.send('API funcionando correctamente'));

// CRUD grupos
app.get('/grupos', async (req, res) => {
    const grupos = await Grupo.find();
    res.json(grupos);
});

app.get('/grupos/:id', async (req, res) => {
    try {
        const grupo = await Grupo.findById(req.params.id);
        if (!grupo) return res.status(404).json({ error: 'Grupo no encontrado' });
        res.json(grupo);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

app.post('/grupos', async (req, res) => {
    try {
        const grupo = new Grupo(req.body);
        await grupo.save();
        res.status(201).json(grupo);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => console.log(`Servidor escuchando en puerto ${PORT}`));
