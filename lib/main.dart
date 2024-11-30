import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/main_view.dart';
import 'package:stikev/screens/dasboard/bottom_navbar.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stikev/database/db_initializer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ProfileController());

  // Cargar archivo de configuración .env
  await dotenv.load(fileName: '.env');
  DBInitializer.initDatabase();

  // Verificar si el token es válido antes de ejecutar la aplicación
  bool isValidToken = await Get.find<ProfileController>().hasValidTokenToday();

  // Ejecutar la app directamente con la vista adecuada
  runApp(MyApp(isValidToken));
}

class MyApp extends StatelessWidget {
  
  final bool isValidToken;
   

  const MyApp(this.isValidToken, {super.key});
  
  @override
  Widget build(BuildContext context) {
    
    return GetMaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppStyles.thirdColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppStyles.appBarTheme,
        colorScheme: const ColorScheme.light(
            primary: AppStyles.thirdColor),
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
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Determinar la vista inicial según la validez del token
      home: isValidToken ? BottomBar(controller:  PageController(initialPage: 1)) : const MainView(),
    );
  }
}
