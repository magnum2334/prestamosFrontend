import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/getX/RouteController.dart';
import 'package:stikev/main_view.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:stikev/utils/widgets/notification_service.dart';


class ProfilePage extends StatelessWidget {
  final VoidCallback? onNavigateToProfile;
  const ProfilePage({Key? key, this.onNavigateToProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    final RouteController routeController = Get.find();
    final LoginController loginController = Get.put(LoginController());
    final notificationService = NotificationService();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.thirdColor,
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, size: 28),
            onPressed: () {
              loginController.clearToken();
              routeController.clearRoutes();
              profileController.clearAllData(); // Llamar al método de logout
              Get.offAll(() => const MainView()); // Redirigir al login
            },
          ),
        ],
      ),
      body: SingleChildScrollView(  // Wrap the entire body in SingleChildScrollView
        child: Column(
          children: [
            // Top portion section with a fixed height
            SizedBox(
              height: 250, // Adjust based on your design
              child: const _TopPortion(),
            ),
            // Main profile content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(() => Text(
                        profileController.name.value,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(height: 8),
                  Text(
                    "¡Bienvenido de nuevo!",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          notificationService.showBasicNotification(
                            title: 'Notificación Básica',
                            body: 'Este es el cuerpo de la notificación básica',
                          );
                        },
                        icon: const Icon(Icons.support, size: 28),
                        label: const Text(
                          "Soporte",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          backgroundColor: AppStyles.thirdColor, // Color de fondo azul
                          foregroundColor: Colors.white, // Color del texto y el ícono
                        ),
                      ),
                      const SizedBox(height: 16), // Space between buttons
                      ElevatedButton.icon(
                        onPressed: onNavigateToProfile,
                        icon: const Icon(Icons.cloud_download_rounded, size: 28),
                        label: const Text(
                          "Sincronización",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          backgroundColor: AppStyles.thirdColor, // Color de fondo azul
                          foregroundColor: Colors.white, // Color del texto y el ícono
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _ProfileInfoRow(),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    "Detalles Adicionales",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Si encuentras un error en la app, por favor repórtalo.",
                    style: TextStyle(fontSize: 15, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({Key? key}) : super(key: key);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("Préstamos Activos", 900),
    ProfileInfoItem("Rutas", 120),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (_items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                ))).toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(item.title)
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color.fromARGB(255, 255, 255, 255), // Color negro
                AppStyles.thirdColor, // Azul oscuro
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=1470&q=80')),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
