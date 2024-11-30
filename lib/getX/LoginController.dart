import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de agregar esta dependencia

class LoginController extends GetxController {
  var ruta = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadToken(); // Cargar el token almacenado al iniciar el controlador
  }

  void setEmail(String newEmail) {
    email.value = newEmail;
  }

  void setPassword(String newPassword) {
    password.value = newPassword;
  }

  void setToken(String newToken) async {
    token.value = newToken;
    await _saveToken(newToken); // Guarda el token en almacenamiento persistente
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (storedToken != null) {
      token.value = storedToken; // Restaura el token si está almacenado
    }
  }

  Future<void> _saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
  }

  Future<void> clearToken() async {
    token.value = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Borra el token del almacenamiento
  }
}
