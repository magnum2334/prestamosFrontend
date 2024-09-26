import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/getX/RouteController.dart';
import 'package:stikev/utils/main_style.dart';

class RoutesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RouteController routeController = Get.find();
    
    // Obtener las rutas a través del controlador de rutas
    List<RouteModel> currentRoutes = routeController.getRoutes();

    // Mostrar el contenido de la pestaña de rutas con un ListView
    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'Rutas Disponibles',
          style: TextStyle(color: Colors.white), // Color blanco para el texto
        ),
        backgroundColor: AppStyles.thirdColor, // Color de fondo definido en AppStyles
        iconTheme:const IconThemeData(color: Colors.white), // Color blanco para los iconos (si hay)
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Espacio superior para bajar la lista
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: currentRoutes.length,
          itemBuilder: (context, index) {
            final route = currentRoutes[index];
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.route,
                  color: Colors.blueAccent,
                  size: 40.0,
                ),
                title: Text(
                  route.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                ),
                onTap: () {
                  
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
