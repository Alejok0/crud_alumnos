import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'registro_alumno.dart'; // Pantalla para agregar o modificar alumno

class ApiService {
  final String apiUrl = "http://127.0.0.1:25577/graphql";

  Future<List<dynamic>> obtenerAlumnos() async {
    try {
      var uri = Uri.parse(apiUrl);

      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "query": """
            query {
              alumnos {
                id
                name
                age
                grade
              }
            }
          """
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']?['alumnos'] ?? [];
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  Future<void> eliminarAlumno(String id) async {
    try {
      var uri = Uri.parse(apiUrl);

      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "query": """
            mutation {
              eliminarAlumno(id: "$id") {
                id
              }
            }
          """
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error en la eliminación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red al eliminar: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService apiService = ApiService();
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  MyApp({required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Alumnos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ListaAlumnos(apiService: apiService),
    );
  }
}

class ListaAlumnos extends StatefulWidget {
  final ApiService apiService;

  ListaAlumnos({required this.apiService});

  @override
  _ListaAlumnosState createState() => _ListaAlumnosState();
}

class _ListaAlumnosState extends State<ListaAlumnos> {
  late Future<List<dynamic>> _alumnosFuture;

  @override
  void initState() {
    super.initState();
    _refrescarLista();
  }

  void _refrescarLista() {
    setState(() {
      _alumnosFuture = widget.apiService.obtenerAlumnos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumnos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refrescarLista,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _alumnosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay alumnos disponibles'));
          }

          var alumnos = snapshot.data!;

          return ListView.builder(
            itemCount: alumnos.length,
            itemBuilder: (context, index) {
              var alumno = alumnos[index];
              return ListTile(
                title: Text(alumno['name']),
                subtitle: Text('${alumno['grade']} - ${alumno['age']} años'),
                onTap: () => _showOptions(context, alumno),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroAlumno(accion: 'agregar'),
            ),
          ).then((_) => _refrescarLista());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showOptions(BuildContext context, alumno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar acción'),
        actions: [
          TextButton(
            child: Text('Modificar'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistroAlumno(
                    accion: 'modificar',
                    alumno: alumno,
                  ),
                ),
              ).then((_) => _refrescarLista());
            },
          ),
          TextButton(
            child: Text('Eliminar'),
            onPressed: () async {
              Navigator.pop(context); // Cerrar el diálogo
              await widget.apiService.eliminarAlumno(alumno['id']);
              _refrescarLista(); // Actualizar la lista
            },
          ),
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
