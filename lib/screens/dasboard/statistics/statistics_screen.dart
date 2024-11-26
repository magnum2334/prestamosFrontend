import 'dart:convert';
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
  int cierreCartera = 0;
  List<dynamic> abonosHoy = [];
  List<dynamic> prestamosHoy = [];

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
          contadorPrestamosActivos = data['contadorPrestamosActivos'].toString();
          abonosHoy = data['abonosHoy'];
          prestamosHoy = data['prestamosHoy'];
          cierreCartera = data['cierreCartera'];
          isLoading = false;
        });
      } else {
        debugPrint('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al hacer la petición: ${e.toString()}');
    }
  }

 exportToPDFAndShare() async {
  // Asegurarse de que no afecte a la UI
  setState(() {
    isLoading = true;
  });

  // Definir el HTML que quieres convertir
  String htmlContent = """
    <html>
      <body>
        <h1 style="color: #3A7D44;">Resumen de Cartera</h1>
        <p style="font-size: 16px; color: #666666;">Este es el total de la cartera: <strong>\$5000</strong></p>
        <p style="font-size: 14px; color: #999999;">Este es el total prestado en préstamos actuales.</p>
      </body>
    </html>
    """;

  // Crear el PDF
  final pdf = pw.Document();

  // Agregar el contenido HTML como texto al PDF
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text(htmlContent),
        );
      },
    ),
  );

  // Obtener el directorio temporal
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/resumen_cartera.pdf');

  // Guardar el archivo PDF
  await file.writeAsBytes(await pdf.save());

  // Compartir el PDF
  await Share.shareXFiles([XFile('${directory.path}/resumen_cartera.pdf')], text: 'Resumen de Cartera');

  setState(() {
    isLoading = false; // Volver a cambiar el estado cuando haya terminado
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
                              'Cerrar Cartera',
                              '\$$cierreCartera',
                              'Este es el total de la cartera'),
                          _buildCard(
                              Icons.monetization_on,
                              'ganancias activas',
                              gananciasTotal,
                              'Este es el total prestado en préstamos actuales'),
                          _buildCard(
                              Icons.payment,
                              'Total a Pagar',
                              totalAPagar,
                              'Este es el total que se debe pagar en el periodo seleccionado'),
                          _buildCard(
                              Icons.attach_money,
                              'Préstamos Activos',
                              contadorPrestamosActivos,
                              'Cantidad de préstamos que están activos actualmente'),
                          const SizedBox(height: 20),
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

  Widget _buildCard(IconData icon, String title, String subtitle, String description) {
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(fontSize: 20, color: Colors.green)),
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
        child: const Text('No hay abonos realizados hoy.', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
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
            const Text('Abonos Realizados Hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
        title: Text(abono['monto'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Fecha: ${abono['fecha']}'),
      ),
    );
  }
}
