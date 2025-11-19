const mongoose = require('mongoose');

const GrupoSchema = new mongoose.Schema({
    nombre: { type: String, required: true },
    descripcion: String
}, { timestamps: true });

module.exports = mongoose.model('Grupo', GrupoSchema);
