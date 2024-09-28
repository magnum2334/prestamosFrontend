import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stikev/getX/ClienteCrontroller.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/utils/alert_helper.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:stikev/utils/route_config.dart';
import 'package:stikev/utils/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

class PayModal {
  static void showCuotasPayBottomSheet(
      BuildContext context, List<dynamic> pagos, valorPrestamo, rutaId, prestamoId) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.thirdColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: const Text(
                  'Cuotas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: pagos.length,
                  itemBuilder: (context, index) {
                    var pago = pagos[index];
                    return GestureDetector(
                      onTap: () {
                        _showPaymentOptionModal(context, pagos, pago,
                            currencyFormatter, valorPrestamo, rutaId, prestamoId);
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cuota N ${pago['numeroCuota']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppStyles.thirdColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCuotaInfoRow(
                                  'Monto:',
                                  currencyFormatter.format(pago['monto']),
                                  Colors.green),
                              _buildCuotaInfoRow(
                                  'Abono:',
                                  currencyFormatter.format(pago['abono']),
                                  Colors.green),
                              _buildCuotaInfoRow('Fecha:', pago['fecha'],
                                  AppStyles.thirdColor),
                              _buildCuotaInfoRow('Días de Mora:',
                                  '${pago['diasMora']}', AppStyles.thirdColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: AppStyles.thirdColor,
                      width: 1,
                    ),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(fontSize: 18, color: AppStyles.thirdColor),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Método para mostrar las opciones de pago
  static void _showPaymentOptionModal(BuildContext context, pagos, dynamic pago,
      NumberFormat currencyFormatter, String valorPrestamo, rutaId, prestamoId) {
    TextEditingController amountController = TextEditingController(
        text: currencyFormatter.format(pago['monto']).replaceAll('\$', ''));
    ValueNotifier<bool> isTotalPayment = ValueNotifier<bool>(true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.thirdColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona el tipo de pago',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: isTotalPayment,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      ListTile(
                        title: const Text('Pago Total',
                            style: TextStyle(color: Colors.white)),
                        leading: Radio<bool>(
                          value: true,
                          groupValue: value,
                          onChanged: (newValue) {
                            isTotalPayment.value = true;
                            amountController.text = currencyFormatter
                                .format(pago['monto'])
                                .replaceAll('\$', '');
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Abono',
                            style: TextStyle(color: Colors.white)),
                        leading: Radio<bool>(
                          value: false,
                          groupValue: value,
                          onChanged: (newValue) {
                            isTotalPayment.value = false;
                            amountController.text = currencyFormatter
                                .format(pago['abono'])
                                .replaceAll('\$', '');
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Valor',
                controller: amountController,
                keyboardType: TextInputType.number,
                prefixIcon: Icon(Icons.attach_money),
                borderNone: true,
                inputFormatters: [
                  CurrencyTextInputFormatter(
                    NumberFormat.currency(
                        decimalDigits: 0, locale: 'es_ES', symbol: ''),
                    enableNegative: false,
                    inputDirection: InputDirection.right,
                  ),
                ],
                height: 70,
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _processPayment(
                    context, amountController, valorPrestamo, pagos, rutaId, prestamoId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Realizar Pago',
                  style: TextStyle(color: AppStyles.thirdColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _processPayment(
      BuildContext context,
      TextEditingController amountController,
      String valorPrestamo,
      List<dynamic> pagos, rutaId, prestamoId) async {
    final valorPrestamoInt =
        int.tryParse(valorPrestamo.replaceAll('\$', '').replaceAll('.', ''));
    final amount = int.tryParse(
        amountController.text.replaceAll('\$', '').replaceAll('.', ''));

    // Verifica el total abonado
    int totalAbono = 0;
    for (var pago in pagos) {
      totalAbono += pago['abono'] as int;
    }

    // Validar si las conversiones son exitosas antes de proceder
    if (valorPrestamoInt != null && amount != null) {
      final result = valorPrestamoInt - totalAbono >= amount;

      if (result) {
        // Realiza la petición a la API para procesar el pago
        try {
          final response = await _makePaymentApiCall(amount, rutaId, prestamoId);
          print('response $response');
          if (response) {
            // Mostrar alerta de éxito
             Get.back(); // Cierra la hoja modal
            Get.back(); // Cierra la hoja anterior
            AlertHelper.showSuccessAlert(context, "Pago exitoso.");
          } else {
            // Manejo del caso de error en la respuesta
            AlertHelper.showErrorAlert(context, response['message']);
          }
        } catch (e) {
          // Manejo del error de la petición
          AlertHelper.showErrorAlert(
              context, "Error al procesar el pago. Intenta nuevamente.");
        }
      } else {
        // Manejo del caso donde result es false
        AlertHelper.showErrorAlert(
            context, "El monto ingresado supera el saldo restante.");
      }
    } else {
      AlertHelper.showErrorAlert(context, "El monto ingresado no es válido.");
    }
  }

  // Simulación de llamada a la API para realizar el pago
  static _makePaymentApiCall(data, rutaId, prestamoId) async {
    // Convertir el mapa a JSON
     var body = {
        'abono':data.toString(),
      };
    final String jsonData = jsonEncode(body);
    final LoginController loginController = Get.put(LoginController());
    final ClientesController clientesController = Get.put(ClientesController());
    try {
      final response = await http.post(
        Uri.parse(AppConfig.rutaPrestamoPagoApiUrl(prestamoId.toString())),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${loginController.token}',
        },
        body: jsonData,
      );
      if (response.statusCode == 201) {
         clientesController.fetchPrestamos(
          AppConfig.rutaPrestamoApiUrl(rutaId.toString()),
          loginController.token.value,
        );
        return true;
      } else {
        // Manejar errores de la respuesta
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Widget _buildCuotaInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black)),
        Text(value, style: TextStyle(color: color)),
      ],
    );
  }
}
