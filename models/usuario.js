const mongoose = require('mongoose');

const UsuarioSchema = new mongoose.Schema({
    nombre: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    edad: Number,
    grupo: { type: mongoose.Schema.Types.ObjectId, ref: 'Grupo' }
}, { timestamps: true });

module.exports = mongoose.model('Usuario', UsuarioSchema);
