import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:stikev/database/tables/table_profile.dart';
import 'package:stikev/utils/route_config.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class ProfileController extends GetxController {
  var userId = 0.obs;
  var email = ''.obs;
  var name = ''.obs;
  var phone = ''.obs;
  var roleId = 0.obs;
  var status = ''.obs;
  var token = ''.obs;
  late Database db;
  static String get dbName => dotenv.env['DB']!;

  // Establecer datos de perfil
  void setProfileData(int userId, String email, String name, String phone,
      int roleId, String status, String token) async {
    this.userId.value = userId;
    this.email.value = email;
    this.name.value = name;
    this.phone.value = phone;
    this.roleId.value = roleId;
    this.status.value = status;
    this.token.value = token;

    // Insertar o actualizar el perfil en la base de datos
    Map<String, dynamic> profileData = {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'roleId': roleId,
      'status': status,
      'token': token,
      'tokenUpdateDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };
    db = await openDatabase(dbName);
    await TableProfile.upsertProfile(db , profileData);
  }

  Future<bool> hasValidTokenToday() async {
    try {
      db = await openDatabase(dbName); // Obtén la instancia de la base de datos
      return await TableProfile.isTokenRegisteredToday(db);
    } catch (e) {
      debugPrint("Error al verificar el token: $e");
      return false; // En caso de error, asume que no hay token válido
    }
  }

  // Limpiar datos del perfil
  Future<void> clearAllData() async {
    userId.value = 0;
    email.value = '';
    name.value = '';
    phone.value = '';
    roleId.value = 0;
    status.value = '';
    token.value = '';
  }

  // Obtener perfil del usuario desde una API remota
  fetchUserProfile(token) async {
    final url = AppConfig.profileApiUrl; // Asegúrate de definir esta URL
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setProfileData(
        jsonResponse['user']['id'],
        jsonResponse['user']['email'],
        jsonResponse['user']['nombre'],
        jsonResponse['user']['telefono'],
        jsonResponse['user']['rolId'],
        jsonResponse['user']['estado'],
        token,
      );
      return jsonResponse;
    } else {
      debugPrint("Error al obtener perfil: ${response.statusCode}");
    }
  }
}
