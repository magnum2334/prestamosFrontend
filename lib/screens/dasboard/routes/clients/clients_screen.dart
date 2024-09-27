import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stikev/screens/dasboard/routes/clients/form_client.dart';
import 'package:stikev/utils/main_style.dart';

class ClientesScreen extends StatelessWidget {
  final int routeId;
  final String routeName;
  final int interes;


  // Recibe el ID de la ruta como parámetro en el constructor
  const ClientesScreen({super.key, required this.routeId, required this.routeName, required  this.interes});

  @override
  Widget build(BuildContext context) {
    // Lista de clientes (puedes obtener esta lista desde un controlador en lugar de un mock)
    final List<String> clientes = ['Cliente 1', 'Cliente 2', 'Cliente 3'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes de $routeName'), 
      ),
      body: ListView.builder(
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(clientes[index]),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white), // Icono de flecha en blanco
            onTap: () {
              // Aquí puedes manejar la acción cuando se selecciona un cliente
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar al formulario de creación de clientes
          Get.to(() => ClienteForm(routeId: routeId, interes: interes)); // Pasar el ID de la ruta al formulario de creación
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
