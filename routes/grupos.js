const express = require('express');
const router = express.Router();
const Grupo = require('../models/grupo');

// Obtener todos los grupos
router.get('/', async (req, res) => {
    const grupos = await Grupo.find();
    res.json(grupos);
});

// Crear grupo
router.post('/', async (req, res) => {
    try {
        const grupo = new Grupo(req.body);
        await grupo.save();
        res.status(201).json(grupo);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Obtener grupo por id
router.get('/:id', async (req, res) => {
    try {
        const grupo = await Grupo.findById(req.params.id);
        if (!grupo) return res.status(404).json({ error: 'Grupo no encontrado' });
        res.json(grupo);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
