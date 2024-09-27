import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:stikev/main_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stikev/utils/main_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        brightness: Brightness.light, // Establece el brillo a claro
        primaryColor: AppStyles.thirdColor, // Color primario de la aplicación
        scaffoldBackgroundColor: Colors.white, // Color de fondo de la pantalla
        appBarTheme: AppStyles.appBarTheme
      ),
      darkTheme: ThemeData.dark(),
      home: const MainView(),
    );
  }
}
