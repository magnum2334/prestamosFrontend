import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/getX/RouteController.dart';
import 'package:stikev/main_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stikev/utils/main_style.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   Get.put(RouteController());
  Get.put(ProfileController());
  // Cargar archivo de configuración .env
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppStyles.thirdColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppStyles.appBarTheme,
        colorScheme: const ColorScheme.light(primary: AppStyles.thirdColor), // Cambia el color primario aquí
        // Ajustes para el DatePicker
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppStyles.thirdColor,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppStyles.appBarTheme.copyWith(
    backgroundColor: Colors.black,
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppStyles.thirdColor,
    onPrimary: Colors.white, // Color blanco para textos sobre fondo primario
    onSurface: Colors.white,  // Color blanco para textos sobre fondo oscuro
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),
      home: const MainView(),
    );
  }
}
