import 'package:flutter/material.dart';

class RegistroAlumno extends StatefulWidget {
  final String accion;
  final dynamic alumno; // Puede ser null si es agregar

  const RegistroAlumno({Key? key, required this.accion, this.alumno})
      : super(key: key);

  @override
  _RegistroAlumnoState createState() => _RegistroAlumnoState();
}

class _RegistroAlumnoState extends State<RegistroAlumno> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.accion == 'modificar' && widget.alumno != null) {
      _nameController.text = widget.alumno['name'];
      _ageController.text = widget.alumno['age'].toString();
      _gradeController.text = widget.alumno['grade'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.accion == 'agregar' ? 'Agregar Alumno' : 'Modificar Alumno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Edad'),
            ),
            TextField(
              controller: _gradeController,
              decoration: InputDecoration(labelText: 'Grado'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.accion == 'agregar' ? 'Agregar' : 'Modificar'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    // Aquí enviarías la mutación GraphQL para agregar o modificar el alumno
    // Puedes usar el ID del alumno si es modificación o usar uno nuevo si es agregar
    Navigator.pop(context);
  }
}
