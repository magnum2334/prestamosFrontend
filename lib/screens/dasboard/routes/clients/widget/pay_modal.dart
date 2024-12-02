import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stikev/getX/ClienteCrontroller.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/utils/alert_helper.dart';
import 'package:stikev/utils/animated_icon.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:stikev/utils/route_config.dart';
import 'package:stikev/utils/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

class PayModal {
  static void showCuotasPayBottomSheet(
      BuildContext context, restante, prestamo) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    Map<String, Widget> getIconAndTextStatus(
        Map<String, dynamic> prestamo, Map<String, dynamic> pago) {
      final Widget icon;
      final String text;
      // Lógica para determinar el ícono y texto a mostrar basado en el pago
      if (pago['monto'] == pago['abono']) {
        icon = const Icon(Icons.check, color: Colors.green);
        text = 'Pagado'; // Texto correspondiente
      } else if (pago['diasMora'] >= 7) {
        icon = const AnimatedIconWidget(iconColor: Colors.red,); // Cambia según tu implementación
        text = 'Mora avanzada'; // Texto correspondiente
      } 
      else if (pago['diasMora'] > 0 && pago['diasMora'] < 7) {
        icon = const AnimatedIconWidget(iconColor: Colors.orange,); // Cambia según tu implementación
        text = 'Mora'; // Texto correspondiente
      } else {
        icon =
            const Icon(Icons.remove_circle_outline_sharp, color: Colors.black);
        text = 'Faltante'; // Texto correspondiente
      }
      // Devuelve un Map con el ícono y el texto
      return {
        'icon': icon,
        'text': Text(
          text,
          style: const TextStyle(
              color: Color.fromARGB(
                  255, 0, 0, 0), // Cambia el color según sea necesario
              fontWeight: FontWeight.bold,
              fontSize: 19),
        ),
      };
    }

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
                  itemCount: prestamo['pagos'].length,
                  itemBuilder: (context, index) {
                    var pago = prestamo['pagos'][index];

                    var statusWidgets = getIconAndTextStatus(prestamo, pago);
                    Widget iconStatus = statusWidgets['icon']!;
                    Widget textStatus = statusWidgets['text']!;

                    return GestureDetector(
                      onTap: () {
                        _showPaymentOptionModal(
                          context,
                          prestamo['pagos'],
                          pago,
                          currencyFormatter,
                          restante,
                          prestamo['rutaId'],
                          prestamo['id'],
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'N° ${pago['numeroCuota']} - ${pago['fecha'].replaceAll('-', '/')}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppStyles.thirdColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildCuotaInfoRow(
                                    'Monto:',
                                    '\$ ${currencyFormatter.format(pago['monto']).replaceAll('\$', '')}',
                                    Colors.green,
                                  ),
                                  _buildCuotaInfoRow(
                                    'Abono:',
                                    '\$ ${currencyFormatter.format(pago['abono']).replaceAll('\$', '')}',
                                    Colors.green,
                                  ),
                                  if (pago['diasMora'] > 0)
                                    _buildCuotaInfoRow(
                                      'Días de Mora:',
                                      '${pago['diasMora']}',
                                      AppStyles.thirdColor,
                                    ),
                                ],
                              ),
                            ),
                            // Posicionamos el ícono en la esquina superior derecha y cambiamos su color según el estado
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Evita que el Row ocupe más espacio del necesario
                                    children: [
                                      textStatus,
                                      const SizedBox(
                                          width:
                                              4), // Espacio entre el texto y el ícono
                                      iconStatus, // Reemplaza esto con tu ícono correspondiente
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
      NumberFormat currencyFormatter, String restante, rutaId, prestamoId) {
    ValueNotifier<bool> isTotalPayment = ValueNotifier<bool>(true);

    final montoData = pago['monto'].toInt();
    final restanteData =
        int.parse(restante.replaceAll('\$', '').replaceAll('.', ''));

// Inicializa el TextEditingController con el valor adecuado
    TextEditingController amountController = TextEditingController(
        text: (restanteData < montoData)
            ? restante.replaceAll(
                '\$', '') // Si restante es menor que montoData, usar restante
            : currencyFormatter
                .format(montoData)
                .replaceAll('\$', '') // De lo contrario, usar montoData
        );

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
                  final montoData = pago['monto'].toInt();
                  final restanteData = int.parse(
                      restante.replaceAll('\$', '').replaceAll('.', ''));

                  print(montoData > restanteData);

                  return Column(
                    children: [
                      if (restanteData < montoData) ...[
                        ListTile(
                          title: const Text('Pago total',
                              style: TextStyle(color: Colors.white)),
                          leading: Radio<bool>(
                            value: false,
                            groupValue: value,
                            onChanged: (newValue) {
                              isTotalPayment.value = false;
                              amountController.text =
                                  restante.replaceAll('\$', '');
                            },
                          ),
                        ),
                      ] else ...[
                        ListTile(
                          title: const Text('Pagar cuota',
                              style: TextStyle(color: Colors.white)),
                          leading: Radio<bool>(
                            value: false,
                            groupValue: value,
                            onChanged: (newValue) {
                              isTotalPayment.value = false;
                              amountController.text = currencyFormatter
                                  .format(pago['monto'])
                                  .replaceAll('\$', '');
                            },
                          ),
                        ),
                      ],
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
                  LengthLimitingTextInputFormatter(11),
                ],
                height: 70,
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _processPayment(context, amountController,
                    restante, pagos, rutaId, prestamoId),
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
      String restante,
      List<dynamic> pagos,
      rutaId,
      prestamoId) async {
    final valorPrestamoInt =
        int.tryParse(restante.replaceAll('\$', '').replaceAll('.', ''));
    final amount = int.tryParse(
        amountController.text.replaceAll('\$', '').replaceAll('.', ''));

    // Validar si las conversiones son exitosas antes de proceder
    if (valorPrestamoInt != null && amount != null) {
      final result = valorPrestamoInt >= amount;

      if (result) {
        // Realiza la petición a la API para procesar el pago
        try {
          final response =
              await _makePaymentApiCall(amount, rutaId, prestamoId);
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
              context, "Error al procesar el pago. Intenta nuevamente. ${e.toString()}");
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
    final LoginController loginController = Get.put(LoginController());
    final ClientesController clientesController = Get.put(ClientesController());
    // ignore: non_constant_identifier_names
    final ProfileController profileController = Get.put(ProfileController());

    var body = {
      'abono': data.toString(),
      'usuarioId': profileController.userId.toString()
    };
    final String jsonData = jsonEncode(body);
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.rutaPrestamoPagoApiUrl(prestamoId.toString())),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${loginController.token}',
        },
        body: jsonData,
      );
      debugPrint('$response');
      debugPrint(AppConfig.rutaPrestamoPagoApiUrl(prestamoId.toString()));
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
       debugPrint(e.toString());
      return false;
    }
  }

  static Widget _buildCuotaInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        Text(value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }
}
