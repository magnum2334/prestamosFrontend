// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // Import intl for DateFormat and NumberFormat
import 'package:stikev/getX/ClienteCrontroller.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:stikev/utils/widgets/custom_text_field.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/route_config.dart';

class ClienteForm extends StatefulWidget {
  final int routeId;
  final int interes;

  const ClienteForm({super.key, required this.routeId, required this.interes});

  @override
  // ignore: library_private_types_in_public_api
  _ClienteFormState createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final TextEditingController valorPrestadoController = TextEditingController();
  final TextEditingController interesController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController identificacionController =
      TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final LoginController loginController = Get.put(LoginController());
  final ClientesController clientesController = Get.put(ClientesController());
  final List<int> cuotasOptions = List<int>.generate(30, (index) => index + 1);
  int selectedCuotas = 0;
  double totalAPagar = 0.0;

  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'es_ES', symbol: '\$', decimalDigits: 0);
  final TextEditingController cuotasController = TextEditingController();
  // Listado de frecuencias de pago
  final List<String> frecuenciaOptions = [
    'Mensual',
    'Quincenal',
    'Semanal',
    'Diaria'
  ];
  String? selectedFrecuencia;

  @override
  void initState() {
    super.initState();
    interesController.text = widget.interes.toString();
    cuotasController.text = selectedCuotas.toString();
  }

  // Añade esta función en la clase _ClienteFormState
  Future<void> enviarDatos() async {
           // Validar que el nombre no esté vacío
      if (nombreController.text.isEmpty) {
        Get.snackbar('Error', 'El nombre es obligatorio.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return; // Evita continuar si el nombre no está presente
      }

      // Validar que el valor prestado no sea vacío o no válido
      int valorPrestado = int.tryParse(valorPrestadoController.text.replaceAll('.', '')) ?? 0;
      if (valorPrestado == 0) {
        Get.snackbar('Error', 'El valor prestado es obligatorio y debe ser un número válido.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return; // Evita continuar si el valor prestado es inválido
      }

      // Validar que el interés no sea vacío o no válido
      int interes = int.tryParse(interesController.text) ?? 0;
      if (interes == 0) {
        Get.snackbar('Error', 'El interés es obligatorio y debe ser un número válido.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return; // Evita continuar si el interés es inválido
      }

      // Validar que se haya seleccionado una cantidad de cuotas
      if (selectedCuotas == null || selectedCuotas <= 0) {
        Get.snackbar('Error', 'Debe seleccionar una cantidad válida de cuotas.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return; // Evita continuar si no se seleccionó una cantidad válida de cuotas
      }

      // Validar que se haya seleccionado una frecuencia
      if (selectedFrecuencia == null ) {
        Get.snackbar('Error', 'Debe seleccionar una frecuencia.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return; // Evita continuar si no se seleccionó una frecuencia
      }

        final ProfileController profileController = Get.find();
        // Crea un mapa con los datos del cliente
        final Map<String, dynamic> cliente = {
          'nombre': nombreController.text,
          'identificacion': identificacionController.text,
          'telefono': telefonoController.text,
          'direccion': direccionController.text,
          'rutaId': widget.routeId,
        };

    // Cálculo del monto de cada cuota
    double interesTotal = (valorPrestado * interes / 100);
    double montoPorCuota = totalAPagar / selectedCuotas;

    // Crea una lista con fechas, montos y número de cada cuota
    List<Map<String, dynamic>> cuotasDetalles =
        _calcularFechasCuotas(DateTime.now()).asMap().entries.map((entry) {
      int index = entry.key;
      DateTime fecha = entry.value;
      return {
        'numeroCuota': index + 1, // Número de cuota
        'fecha': DateFormat('dd-MM-yyyy').format(fecha), // Fecha de pago
        'monto': montoPorCuota.toInt(), // Monto de la cuota
      };
    }).toList();

    // Crea un mapa con los datos del préstamo
    final Map<String, dynamic> prestamo = {
      'valorPrestado':
          int.parse(valorPrestadoController.text.replaceAll('.', '')),
      'codigo': 'codigo',
      'valorTotal': (interesTotal + valorPrestado).toInt(),
      'saldo': 0,
      'cuotas': selectedCuotas,
      'rutaId': widget.routeId,
      'estadoId': 1,
      'cobradorId': profileController.userId.value,
      'frecuencia': selectedFrecuencia,
      'interes': interes,
    };

    // Combina los datos en un solo mapa con las llaves cliente y prestamo
    final Map<String, dynamic> data = {
      'cliente': cliente,
      'prestamo': prestamo,
      'cuotasDetalles': cuotasDetalles, // Incluye detalles de las cuotas
    };

    // Convertir el mapa a JSON
    final String jsonData = jsonEncode(data);
    debugPrint(AppConfig.clientApiUrl);
    debugPrint("${loginController.token}" );
    
      final response = await http.post(
        Uri.parse(AppConfig.clientApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${loginController.token}',
        },
        body: jsonData,
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        // Si la respuesta es exitosa, manejar la respuesta aquí
        clientesController.fetchPrestamos(
          AppConfig.rutaPrestamoApiUrl(widget.routeId.toString()),
          loginController.token.value,
        );
        Get.back();
      } else {
        // Manejar errores de la respuesta
        debugPrint('Error al enviar los datos: ${response.statusCode}');
      }
   
  }

  void _calcularTotal() {
    int valorPrestado =
        int.tryParse(valorPrestadoController.text.replaceAll('.', '')) ?? 0;
    int interes = int.tryParse(interesController.text) ?? widget.interes;
    double interesTotal = (valorPrestado * interes / 100);
    setState(() {
      totalAPagar = valorPrestado + interesTotal;
    });
  }

  // Función para calcular las fechas de las cuotas según la frecuencia
  List<DateTime> _calcularFechasCuotas(DateTime startDate) {
    List<DateTime> fechasCuotas = [];
    DateTime currentDate = startDate;

    for (int i = 0; i < selectedCuotas; i++) {
      switch (selectedFrecuencia) {
        case 'Mensual':
          currentDate = DateTime(
              currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        case 'Quincenal':
          currentDate = currentDate.add(const Duration(days: 15));
          break;
        case 'Semanal':
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case 'Diaria':
          // Avanzar al día siguiente, pero evitar domingos
          do {
            currentDate = currentDate.add(const Duration(days: 1));
          } while (currentDate.weekday == DateTime.sunday); // Saltar domingos
          break;
      }
      fechasCuotas.add(currentDate);
    }

    return fechasCuotas;
  }

  void _updateCuotas(String value) {
    int parsedValue = int.tryParse(value) ??
        1; // Si el parsing falla, establece el valor por defecto en 1
    setState(() {
      selectedCuotas = parsedValue;
      _calcularTotal(); // Recalcular el total al cambiar las cuotas
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Ruta: ${widget.routeId}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: nombreController,
                labelText: 'Nombre',
                prefixIcon: const Icon(Icons.person),
                height: 70,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: identificacionController,
                labelText: 'Identificación',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.credit_card),
                obscureText: true,
                height: 70,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: telefonoController,
                labelText: 'Teléfono',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
                height: 70,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: direccionController,
                labelText: 'Dirección',
                prefixIcon: const Icon(Icons.home),
                height: 70,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: valorPrestadoController,
                labelText: 'Valor Prestado',
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
                onChanged: (value) {
                  _calcularTotal();
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: interesController,
                labelText: 'Tasa de Interés (%)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.percent),
                height: 70,
                onChanged: (value) {
                  _calcularTotal();
                },
              ),
              const SizedBox(height: 10),

              CustomTextField(
                controller: cuotasController,
                labelText: 'Cuotas',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.calendar_today),
                height: 70,
                onChanged: _updateCuotas,
                validator: (value) {
                  final number = int.tryParse(value ?? '');
                  debugPrint('$number');
                  if (number == null || number < 1 || number > 30) {
                    return 'la cuota debe estar entre 1 y 30';
                  }
                  return null; 
                },
              ),
              const SizedBox(height: 10),

              // Dropdown para seleccionar la frecuencia
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Frecuencia de Pago',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: frecuenciaOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFrecuencia = value;
                    _calcularTotal();
                  });
                },
                isExpanded: true,
                hint: const Text('Seleccione la frecuencia de pago'),
              ),

              const SizedBox(height: 20),
              Text(
                'Valor Total del Préstamo: ${currencyFormatter.format(totalAPagar)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (selectedCuotas > 0 &&
                  selectedFrecuencia != null &&
                  valorPrestadoController.value != '' &&
                  interesController.value != '')
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(AppStyles.thirdColor),
                    columns: const [
                      DataColumn(
                        label: Text('Cuota',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('Monto',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('Fecha',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                    rows: List<DataRow>.generate(selectedCuotas, (index) {
                      double montoCuota = totalAPagar / selectedCuotas;
                      DateTime startDate = DateTime.now();
                      switch (selectedFrecuencia) {
                        case 'Mensual':
                          startDate.add(Duration(
                              days: DateTime(
                                      startDate.year, startDate.month + 1, 0)
                                  .day // Obtiene el último día del mes
                              ));
                          break;
                        case 'Quincenal':
                          startDate.add(const Duration(days: 15));
                          break;
                        case 'Semanal':
                          startDate.add(const Duration(days: 7));
                          break;
                      }
                      List<DateTime> fechas = _calcularFechasCuotas(startDate);

                      return DataRow(
                        cells: [
                          DataCell(Text('N  ${index + 1}',
                              style: const TextStyle(fontSize: 14))),
                          DataCell(Text(
                              "\$ ${currencyFormatter.format(montoCuota).replaceAll('\$', '')}",
                              style: const TextStyle(fontSize: 14))),
                          DataCell(Text(
                              DateFormat('dd/MM/yyyy').format(fechas[index]),
                              style: const TextStyle(fontSize: 14))),
                        ],
                      );
                    }),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  enviarDatos();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.thirdColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Crear Cliente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
