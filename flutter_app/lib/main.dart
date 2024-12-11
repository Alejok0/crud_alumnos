import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'registro_alumno.dart'; // Pantalla para agregar o modificar alumno

class ApiService {
  // Cambia "127.0.0.1" por "10.0.2.2" si estás usando un emulador de Android
  final String apiUrl = "http://127.0.0.1:4000/graphql";

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
      if (response.statusCode != 200) {
        print('Error HTTP: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }


      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['data'] != null &&
            jsonResponse['data']['alumnos'] != null) {
          return jsonResponse['data']['alumnos'];
        } else {
          // Retornar un error si no se encuentran los datos
          return [];
        }
      } else {
        // Error en la respuesta HTTP
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de excepciones de red
      throw Exception('Error de red: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de API
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaAlumnos(apiService: apiService),
    );
  }
}

class ListaAlumnos extends StatelessWidget {
  final ApiService apiService;

  ListaAlumnos({required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alumnos')),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.obtenerAlumnos(),
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
          );
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
              );
            },
          ),
          TextButton(
            child: Text('Eliminar'),
            onPressed: () {
              // Aquí iría la lógica para eliminar el alumno
              // Por ejemplo, una mutación GraphQL para eliminarlo
            },
          ),
        ],
      ),
    );
  }
}
