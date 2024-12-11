const mongoose = require('mongoose');

const alumnoSchema = new mongoose.Schema({
  name: { type: String, required: true },
  age: { type: Number, required: true },
  grade: { type: String, required: true },
});

module.exports = mongoose.model('Alumno', alumnoSchema);
