import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'dart:convert';

import 'package:stikev/utils/main_style.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/utils/route_config.dart';
import 'package:stikev/utils/widgets/custom_text_field.dart';

class GastoController extends GetxController {
  final valorGasto = ''.obs;
  final descripcionGasto = ''.obs;
  final isSaving = false.obs;

  // Agregar TextEditingController
  final valorController = TextEditingController();
  final descripcionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    valorController.addListener(() {
      valorGasto.value = valorController.text;
    });
    descripcionController.addListener(() {
      descripcionGasto.value = descripcionController.text;
    });
  }

  @override
  void onClose() {
    valorController.dispose();
    descripcionController.dispose();
    super.onClose();
  }

  Future<void> guardarGasto() async {
    final LoginController loginController = Get.put(LoginController());
    final ProfileController profileController = Get.put(ProfileController());

    if (valorGasto.isNotEmpty && descripcionGasto.isNotEmpty) {
      isSaving.value = true;

      final url = Uri.parse(AppConfig.gastoApiUrl);
      final body = {
        'valor': int.parse(valorGasto.value.toString().replaceAll('.', '')),
        'descripcion': descripcionGasto.value.toString(),
        'fecha': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'usuarioId':  int.parse(profileController.userId.toString()),
      };

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${loginController.token}',
          },
          body: json.encode(body),
        );

        if (response.statusCode == 201) {
          print(response.body);
         
          Get.snackbar(
            'Éxito',
            'Gasto guardado correctamente',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[400],
            colorText: Colors.white,
          );

          // Reiniciar campos
          valorGasto.value = '';
          descripcionGasto.value = '';
          valorController.clear();
          descripcionController.clear();
        } else {
          Get.snackbar(
            'Error',
            'No se pudo guardar el gasto: ${response.body}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[400],
            colorText: Colors.white,
          );
           valorGasto.value = '';
            descripcionGasto.value = '';
            valorController.clear();
            descripcionController.clear();
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Ocurrió un problema: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      } finally {
        isSaving.value = false;
      }
    } else {
      Get.snackbar(
        'Error',
        'Complete todos los campos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[400],
        colorText: Colors.white,
      );
    }
  }
}

class GastoScreen extends StatelessWidget {
  final GastoController controller = Get.put(GastoController());

  @override
  Widget build(BuildContext context) {
    final String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar Gastos',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.date_range,
                          color: AppStyles.thirdColor),
                      title: Text(
                        'Fecha: $fechaHoy',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CustomTextField(
                      labelText: 'Valor',
                      controller: controller.valorController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money),
                      inputFormatters: [
                        CurrencyTextInputFormatter(
                          NumberFormat.currency(
                              decimalDigits: 0, locale: 'es_ES', symbol: ''),
                          enableNegative: false,
                          inputDirection: InputDirection.right,
                        ),
                        LengthLimitingTextInputFormatter(11),
                      ],
                      height: 70,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      labelText: 'Observación',
                      controller: controller.descripcionController,
                      keyboardType: TextInputType.streetAddress,
                      prefixIcon: const Icon(Icons.text_snippet),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(150),
                      ],
                      height: 70,
                    ),
                    const SizedBox(height: 20),
                    // Wrap only the button with Obx to update its state based on isSaving, valorGasto, and descripcionGasto
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.valorGasto.isNotEmpty &&
                                controller.descripcionGasto.isNotEmpty &&
                                !controller.isSaving.value
                            ? controller.guardarGasto
                            : null,
                        icon: controller.isSaving.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          controller.isSaving.value
                              ? 'Guardando...'
                              : 'Guardar',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.valorGasto.isNotEmpty &&
                                  controller.descripcionGasto.isNotEmpty &&
                                  !controller.isSaving.value
                              ? AppStyles.thirdColor
                              : Colors.black12,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
