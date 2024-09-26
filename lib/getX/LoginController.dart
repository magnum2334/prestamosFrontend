import 'package:get/get.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var token = ''.obs; // Agregamos la variable para el token

  void setEmail(String newEmail) {
    email.value = newEmail;
  }

  void setPassword(String newPassword) {
    password.value = newPassword;
  }

  void setToken(String newToken) { // Método para actualizar el token
    token.value = newToken;
  }

  // Función genérica para obtener datos
  T getData<T>(Rx<T> data) {
    return data.value;
  }
}
