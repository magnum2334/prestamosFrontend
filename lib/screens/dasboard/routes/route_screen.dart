import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:stikev/getX/RouteController.dart';
import 'package:stikev/screens/dasboard/routes/clients/clients_screen.dart';
import 'package:stikev/screens/dasboard/routes/clients/widget/gasto_screen.dart';
import 'package:stikev/utils/main_style.dart';



class RoutesWidget extends StatefulWidget {
  final List<dynamic> routes; // Recibe las rutas como parámetro

  const RoutesWidget({Key? key, required this.routes}) : super(key: key);

  @override
  _RoutesWidgetState createState() => _RoutesWidgetState();
}

class _RoutesWidgetState extends State<RoutesWidget> {
  late List<dynamic> currentRoutes;

  @override
  void initState() {
    super.initState();
    // Usa las rutas pasadas como parámetro
    currentRoutes = widget.routes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rutas Disponibles',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppStyles.thirdColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money_sharp),
            tooltip: 'Gastos',
            onPressed: () {
              Get.to(
                () => GastoScreen(),
                transition: Transition.cupertinoDialog,
                duration: const Duration(milliseconds: 500),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: currentRoutes.length,
          itemBuilder: (context, index) {
            final route = currentRoutes[index];

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.route,
                  color: AppStyles.thirdColor,
                  size: 40.0,
                ),
                title: Text(
                  route['name'],
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
                  Get.to(
                    () => ClientesScreen(
                      routeId: route['id'],
                      routeName: route['name'],
                      interes: route['interes']
                    ),
                    transition: Transition.cupertinoDialog,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
