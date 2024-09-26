import 'package:get/get.dart';

class ProfileController extends GetxController {
  var userId = 0.obs;
  var email = ''.obs;
  var name = ''.obs;
  var phone = ''.obs;
  var roleId = 0.obs;
  var status = ''.obs;

  // Método para actualizar los datos del perfil
  void setProfileData(int id, String email, String name, String phone, int roleId, String status) {
    userId.value = id;
    this.email.value = email;
    this.name.value = name;
    this.phone.value = phone;
    this.roleId.value = roleId;
    this.status.value = status;
  }

  // Función genérica para obtener datos
  T getData<T>(Rx<T> data) {
    return data.value;
  }

  // Método para obtener y mostrar todos los datos del perfil
  void displayProfileData() {
    print('User ID: ${userId.value}');
    print('Email: ${email.value}');
    print('Name: ${name.value}');
    print('Phone: ${phone.value}');
    print('Role ID: ${roleId.value}');
    print('Status: ${status.value}');
  }
}
