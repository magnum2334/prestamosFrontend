import 'package:flutter/material.dart';

class AppStyles {
  static const Color text = Color.fromARGB(255, 2, 51, 86);
  static const Color thirdColor = Color.fromARGB(255, 9, 38, 130);

  // Método para obtener el AppBarTheme
  static AppBarTheme get appBarTheme {
    return const AppBarTheme(
      backgroundColor: thirdColor, // Color de fondo de la AppBar
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Color del texto de la AppBar
      iconTheme: IconThemeData(color: Colors.white), // Color de los iconos de la AppBar
    );
  }
}
