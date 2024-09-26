import 'package:get/get.dart';

class RouteController extends GetxController {
  var routes = <RouteModel>[].obs; // Lista observable de rutas

  // Método para añadir una nueva ruta
  void addRoute(RouteModel route) {
    routes.add(route);
  }

  // Método para retornar el array de rutas
  List<RouteModel> getRoutes() {
    return routes.toList(); // Retorna una copia de la lista de rutas
  }

  // Método para cargar rutas desde un JSON
  void loadRoutes(List<dynamic> jsonData) {
    routes.value = jsonData.map((json) => RouteModel.fromJson(json)).toList();
  }
}

class RouteModel {
  final int id;                      // ID de la ruta
  final String name;                 // Nombre de la ruta
  final int cobradorId;              // ID del cobrador
  final double interes;              // Interés
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
      interes: json['interes'].toDouble(), // Asegura que sea un double
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
