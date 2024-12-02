// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/getX/ProfileController.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:stikev/utils/route_config.dart';
import 'package:stikev/utils/widgets/custom_date_picker.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TextEditingController fechaInicioController = TextEditingController();
  final TextEditingController fechaFinController = TextEditingController();
  final ProfileController profileController = Get.find();
  final LoginController _loginController = Get.put(LoginController());

  bool isLoading = true;
  String gananciasTotal = '';
  String totalAPagar = '';
  String contadorPrestamosActivos = '';
  int totalGastosHoy = 0;
  int cierreCartera = 0;
  List<dynamic> abonosHoy = [];
  List<dynamic> prestamosHoy = [];
  List<dynamic> gastosHoy = [];
  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'es_ES', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    fechaInicioController.text = hoy.toIso8601String().split('T').first;
    fechaFinController.text = hoy.toIso8601String().split('T').first;
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final String fechaInicio = fechaInicioController.text;
    final String fechaFin = fechaFinController.text;
    final String url = AppConfig.cartera(
      profileController.userId.toString(),
      fechaInicio,
      fechaFin,
    );

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${_loginController.token}',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          gananciasTotal = data['gananciasTotal'].toString();
          contadorPrestamosActivos =
              data['contadorPrestamosActivos'].toString();
          abonosHoy = data['abonosHoy'];
          prestamosHoy = data['prestamosHoy'];
          cierreCartera = data['cierreCartera'];
          gastosHoy = data['gastosHoy'];
          totalGastosHoy = data['totalGastosHoy'];
          isLoading = false;
        });
      } else {
        debugPrint('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al hacer la petición: ${e.toString()}');
    }
  }

  Future<void> exportToPDFAndShare() async {
    setState(() {
      isLoading = true; // Mostrar indicador de carga mientras se genera el PDF
    });

    // Crear el documento PDF
    final pdf = pw.Document();
    final String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Crear contenido dinámico basado en los datos obtenidos
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          // Título con la fecha actual
          pw.Center(
            child: pw.Text(
              "Resumen de Cartera \n         $fechaHoy",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // Ganancias totales y préstamos activos
          pw.Text(
            "Ganancias Totales: ${gananciasTotal.isNotEmpty ? '\$${currencyFormatter.format(cierreCartera).replaceAll('\$', '')}' : 'Sin datos'}\n"
            "Gastos Totales: ${gananciasTotal.isNotEmpty ? '\$${currencyFormatter.format(totalGastosHoy).replaceAll('\$', '')}' : 'Sin datos'}\n"
            "Préstamos Activos: ${contadorPrestamosActivos.isNotEmpty ? contadorPrestamosActivos : 'Sin datos'}",
            style: const pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 10),

          // Tabla de Préstamos realizados hoy
          pw.Text(
            "Préstamos Realizados Hoy:",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          prestamosHoy.isNotEmpty
              ? pw.Table.fromTextArray(
                  headers: [
                    'Código',
                    'Valor Prestado',
                    'ValorTotal',
                    'interes',
                    'Cuotas',
                    'Frecuencia',
                    'Fecha Creación',
                  ],
                  data: prestamosHoy.map((prestamo) {
                    return [
                      "KAC-${prestamo['id']}",
                      "\$${currencyFormatter.format(prestamo['valorPrestado']).replaceAll('\$', '')}",
                      "\$${currencyFormatter.format(prestamo['valorTotal']).replaceAll('\$', '')}",
                      "${prestamo['interes']}%",
                      prestamo['cuotas'].toString(),
                      prestamo['frecuencia'],
                      prestamo['fecha_creacion']
                          .replaceAll('T', ' ')
                          .split('.')[0],
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 12),
                  border: pw.TableBorder.all(width: 1),
                  cellAlignment:
                      pw.Alignment.center, // Centrar encabezados y celdas
                )
              : pw.Text(
                  "No hay préstamos realizados hoy.",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
          pw.SizedBox(height: 20),

          // Tabla de Abonos realizados hoy
          pw.Text(
            "Abonos Realizados Hoy:",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          abonosHoy.isNotEmpty
              ? pw.Table.fromTextArray(
                  headers: ['Ruta', 'Cliente', 'Monto', 'Fecha'],
                  data: abonosHoy.map((abono) {
                    return [
                      abono['prestamo']['ruta']['nombre'],
                      abono['prestamo']['Cliente']['nombre'],
                      "\$${currencyFormatter.format(abono['monto']).replaceAll('\$', '')}",
                      abono['fecha'].replaceAll('T', ' ').split('.')[0],
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 12),
                  border: pw.TableBorder.all(width: 1),
                  cellAlignment:
                      pw.Alignment.center, // Centrar encabezados y celdas
                )
              : pw.Text(
                  "No hay abonos realizados hoy.",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
         
          pw.SizedBox(height: 20),
           pw.Text(
            "gastos del hoy:",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
           pw.SizedBox(height: 20),
          gastosHoy.isNotEmpty
              ? pw.Table.fromTextArray(
                  headers: [
                    'Código',
                    'Valor',
                    'Descripción',
                    'Fecha',
                  ],
                  data: gastosHoy.map((gasto) {
                    return [
                      "GASTO-${gasto['id']}", // Generamos el código del gasto
                      "\$${currencyFormatter.format(gasto['valor']).replaceAll('\$', '')}", // Formato de valor
                      gasto['descripcion'], // Descripción
                      gasto['fecha'].split('T')[0]  // Fecha formateada
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 12),
                  border: pw.TableBorder.all(width: 1),
                  cellAlignment:
                      pw.Alignment.center, // Centrar encabezados y celdas
                )
              : pw.Text(
                  "No hay gastos realizados hoy.",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
        ],
      ),
    );

    // Guardar el archivo PDF en el almacenamiento temporal
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/resumen_cartera.pdf');
    await file.writeAsBytes(await pdf.save());

    // Compartir el archivo PDF
    await Share.shareXFiles([XFile(file.path)], text: 'Resumen de Cartera');

    setState(() {
      isLoading = false; // Ocultar el indicador de carga
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Cartera'),
        actions: [
          ElevatedButton(
            onPressed: fetchData,
            child: const Icon(Icons.refresh, color: AppStyles.thirdColor),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: exportToPDFAndShare,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppStyles.thirdColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DatePickerBox(
                    controller: fechaInicioController,
                    labelText: 'Fecha Inicio',
                    height: 60,
                  ),
                  const SizedBox(width: 10),
                  DatePickerBox(
                    controller: fechaFinController,
                    labelText: 'Fecha Fin',
                    height: 60,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView(
                        children: [
                          _buildCard(
                              Icons.account_balance,
                              'Cartera del dia',
                              '\$ ${currencyFormatter.format(cierreCartera).replaceAll('\$', '')}',
                              'total de la cartera del dia'),
                          _buildCard(
                              Icons.attach_money,
                              'gastos del dia',
                              '\$ ${currencyFormatter.format(totalGastosHoy).replaceAll('\$', '')}',
                              'Cantidad de préstamos que están activos actualmente'),
                          _buildCard(
                              Icons.attach_money,
                              'Préstamos Activos',
                              contadorPrestamosActivos,
                              'Cantidad de préstamos que están activos actualmente'),
                          _buildAbonosList(),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      IconData icon, String title, String subtitle, String description) {
    return Card(
      color: Colors.white,
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppStyles.thirdColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 20, color: Colors.green)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbonosList() {
    if (abonosHoy.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: const Text('No hay abonos realizados hoy.',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Abonos Realizados Hoy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: abonosHoy.length,
              itemBuilder: (context, index) {
                return _buildAbonoTile(abonosHoy[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbonoTile(Map<String, dynamic> abono) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.payment, color: Colors.green),
        title: Text(
            "Ruta: ${abono['prestamo']['ruta']['nombre'].toString()}\nCliente: ${abono['prestamo']['Cliente']['nombre'].toString()}\nMonto:${abono['monto'].toString()}\n ",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text("fecha: ${abono['fecha'].replaceAll('T', ' ').split('.')[0]}"),
      ),
    );
  }
}
