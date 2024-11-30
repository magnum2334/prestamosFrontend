import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stikev/utils/route_config.dart'; 

class RouteController extends GetxController {
  var routes = <RouteModel>[].obs;

  
  @override
  void onInit() {
    super.onInit();
    _loadRoutes();
  }

   Future<void> fetchRoutesByCobrador(token, cobradorId) async {
    final url = AppConfig.rutaCobradorApiUrl(cobradorId.toString());

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Bearer $token', // Añade el token Bearer
      },
    );

    if (response.statusCode == 200) {
      var data =
          jsonDecode(response.body) as List; // Asegúrate de que es una lista
      // Cargar las rutas en el controlador
      List<Map<String, dynamic>> routes = data.map((item) {
        // Asegúrate de manejar posibles campos null
        return {
          'id': item['id'] ?? '', // Proporciona un valor predeterminado
          'nombre': item['nombre'] ?? '',
          'cobradorId': item['cobradorId'] ?? 0,
          'interes': item['interes'] ?? 0,
          'tMaximoPrestamo': item['tMaximoPrestamo'] ?? 0.0,
          'interesLibre': item['interesLibre'] ?? false,
          'fecha_creacion': item['fecha_creacion'] ?? '',
          'capitalId': item['capitalId'] ?? 0,
        };
      }).toList();
      loadRoutes(routes);
    } else {
      // Manejo del error
      debugPrint("Error al obtener rutas: ${response.statusCode}");
    }
  }

  // Método para añadir una nueva ruta
  void addRoute(RouteModel route) {
    routes.add(route);
    _saveRoutes();
  }

  // Método para retornar el array de rutas
  List<RouteModel> getRoutes() {
    return routes.toList(); // Retorna una copia de la lista de rutas
  }

  // Método para cargar rutas desde un JSON
  void loadRoutes(List<dynamic> jsonData) {
    routes.value = jsonData.map((json) => RouteModel.fromJson(json)).toList();
    _saveRoutes(); // Guardar rutas después de cargar desde JSON
  }

  // Método para guardar las rutas en SharedPreferences
  Future<void> _saveRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonRoutes = routes.map((route) => route.toJson()).toList();
    String jsonString = json.encode(jsonRoutes); // Convertir las rutas a una cadena JSON
    await prefs.setString('routes', jsonString); // Guardar en SharedPreferences
  }

  // Método para cargar las rutas desde SharedPreferences
  Future<void> _loadRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('routes');
    if (jsonString != null && jsonString.isNotEmpty) {
      List<dynamic> jsonData = json.decode(jsonString); // Convertir la cadena JSON de nuevo a una lista
      routes.value = jsonData.map((json) => RouteModel.fromJson(json)).toList(); // Asignar las rutas a la lista observable
    }
  }

  // Método para eliminar las rutas almacenadas en SharedPreferences
  Future<void> clearRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('routes'); // Eliminar las rutas de SharedPreferences
    routes.clear(); // Limpiar la lista observable de rutas
  }
}

class RouteModel {
  final int id;                      // ID de la ruta
  final String name;                 // Nombre de la ruta
  final int cobradorId;              // ID del cobrador
  final int interes;                 // Interés
  final double tMaximoPrestamo;      // Monto máximo del préstamo
  final bool interesLibre;           // Si es libre de interés
  final DateTime fechaCreacion;      // Fecha de creación
  final int capitalId;               // ID del capital

  RouteModel({
    required this.id,
    required this.name,
    required this.cobradorId,
    required this.interes,
    required this.tMaximoPrestamo,
    required this.interesLibre,
    required this.fechaCreacion,
    required this.capitalId,
  });

  // Método para crear una instancia de RouteModel a partir de un JSON
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      name: json['nombre'], // Cambia 'nombre' a 'name'
      cobradorId: json['cobradorId'],
      interes: json['interes'].toInt(), // Asegura que sea un double
      tMaximoPrestamo: json['tMaximoPrestamo'].toDouble(), // Asegura que sea un double
      interesLibre: json['interesLibre'], // Se asume que es un bool
      fechaCreacion: DateTime.parse(json['fecha_creacion']), // Convierte a DateTime
      capitalId: json['capitalId'],
    );
  }

  // Método para convertir una instancia de RouteModel a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name, // Cambia 'name' a 'nombre'
      'cobradorId': cobradorId,
      'interes': interes,
      'tMaximoPrestamo': tMaximoPrestamo,
      'interesLibre': interesLibre,
      'fecha_creacion': fechaCreacion.toIso8601String(), // Convierte a String
      'capitalId': capitalId,
    };
  }
}
