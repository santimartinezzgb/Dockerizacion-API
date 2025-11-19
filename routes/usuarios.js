const express = require('express');
const router = express.Router();
const Usuario = require('../models/usuario');

// Obtener todos los usuarios
router.get('/', async (req, res) => {
    const usuarios = await Usuario.find().populate('grupo');
    res.json(usuarios);
});

// Crear usuario
router.post('/', async (req, res) => {
    try {
        const usuario = new Usuario(req.body);
        await usuario.save();
        res.status(201).json(usuario);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Obtener usuario por id
router.get('/:id', async (req, res) => {
    try {
        const usuario = await Usuario.findById(req.params.id).populate('grupo');
        if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' });
        res.json(usuario);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
