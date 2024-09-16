import 'package:get/get.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;

  void setEmail(String newEmail) {
    email.value = newEmail;
  }

  void setPassword(String newPassword) {
    password.value = newPassword;
  }

  // Función genérica para obtener datos
  T getData<T>(Rx<T> data) {
    return data.value;
  }
}
