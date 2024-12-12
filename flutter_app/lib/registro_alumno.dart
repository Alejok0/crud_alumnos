import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> _submit() async {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final grade = _gradeController.text;

    if (name.isEmpty || age <= 0 || grade.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final url = Uri.parse('http://127.0.0.1:25577/graphql');
    final headers = {'Content-Type': 'application/json'};

    String query;
    if (widget.accion == 'agregar') {
      query = '''
        mutation {
          addAlumno(name: "$name", age: $age, grade: "$grade") {
            id
            name
            age
            grade
          }
        }
      ''';
    } else {
      final id = widget.alumno['id'];
      query = '''
        mutation {
          updateAlumno(id: "$id", name: "$name", age: $age, grade: "$grade") {
            id
            name
            age
            grade
          }
        }
      ''';
    }

    final body = json.encode({'query': query});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errors'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['errors'][0]['message']}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Operación exitosa')),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en la conexión con el servidor')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
