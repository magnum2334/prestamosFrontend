import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ClientesController extends GetxController {
  var prestamos = <dynamic>[].obs;
  var isLoading = true.obs;

  Future<void> fetchPrestamos(String url, String token) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List<dynamic>;
        prestamos.value = [];
        prestamos.value = data;
      } else {
        debugPrint("Error al obtener préstamos: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error en la petición: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
