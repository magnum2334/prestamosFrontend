import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stikev/utils/route_config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stikev/database/tables/table_route.dart';

class RouteController extends GetxController {
  
  late Database db;
  var routes = <Map<String, dynamic>>[].obs;
  static String get dbName => dotenv.env['DB']!;

  // Inicializar la base de datos
  Future<void> _initDatabase() async {
    db = await openDatabase(dbName); 
  }

  @override
  void onInit() {
    _initDatabase();
    super.onInit();
  }

  // Obtener las rutas desde la base de datos
  Future<void> _loadRoutes() async {
    final fetchedRoutes = await TableRoute.getRoutes(db);
    routes.value = fetchedRoutes;
  }

  // Fetch routes from an API and store them in the local database
  Future<void> fetchRoutesByCobrador(String token, int cobradorId) async {
    final url = AppConfig.rutaCobradorApiUrl(cobradorId.toString());

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List;

      // Convert the response data into a list of maps
      List<Map<String, dynamic>> routeData = data.map((item) {
        return {
          'id': item['id'],
          'name': item['nombre'],
          'cobradorId': item['cobradorId'],
          'interes': item['interes'],
          'tMaximoPrestamo': item['tMaximoPrestamo'],
          'interesLibre': item['interesLibre'] ? 1 : 0,
          'fecha_creacion': item['fecha_creacion'],
          'capitalId': item['capitalId'],
        };
      }).toList();

      // Insert or update routes in the database
      for (var route in routeData) {
        await TableRoute.upsertRoute(db, route);
      }

      // Reload routes from the database
      await _loadRoutes();
    } else {
      debugPrint("Error al obtener rutas: ${response.statusCode}");
    }
  }

  // Add a new route
  void addRoute(Map<String, dynamic> route) async {
    await TableRoute.upsertRoute(db, route);
    await _loadRoutes(); // Reload the routes after adding a new one
  }

  // Remove all routes
  void clearRoutes() async {
    await TableRoute.deleteRoutes(db);
    routes.clear();
  }
}

