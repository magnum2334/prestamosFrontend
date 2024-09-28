import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stikev/getX/ClienteCrontroller.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/screens/dasboard/routes/clients/form_client_sreem.dart';
import 'package:stikev/screens/dasboard/routes/clients/widget/pay_modal.dart';
import 'package:stikev/utils/main_style.dart';
import 'package:stikev/utils/route_config.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientesScreen extends StatefulWidget {
  final int routeId;
  final String routeName;
  final int interes;

  const ClientesScreen({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.interes,
  });

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final LoginController loginController = Get.put(LoginController());
  final ClientesController clientesController = Get.put(ClientesController());
  List<dynamic> prestamos = [];
  bool isLoading = true;
  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'es_ES', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Fetch the prestamos initially
    clientesController.fetchPrestamos(
      AppConfig.rutaPrestamoApiUrl(widget.routeId.toString()),
      loginController.token.value,
    );
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.simpleCurrency(locale: 'es_CO');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes de ${widget.routeName}'),
      ),
      body: Obx(
        () => clientesController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await clientesController.fetchPrestamos(
                    AppConfig.rutaPrestamoApiUrl(widget.routeId.toString()),
                    loginController.token.value,
                  );
                },
                child: clientesController.prestamos.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: clientesController.prestamos.length,
                        itemBuilder: (context, index) {
                          final prestamo = clientesController.prestamos[index];

                          // Calcular el valor abonado
                          final abonado = prestamo['pagos']
                              .fold(0, (sum, pago) => sum + pago['abono']);

                          // Calcular el valor restante
                          final restante = prestamo['valorTotal'] - abonado;

                          return Card(
                            color: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nombre: ${prestamo['Cliente']['nombre']}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppStyles.thirdColor,
                                            ),
                                          ),
                                          Text(
                                            'Código: ${prestamo['codigo']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppStyles.thirdColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        Icons.more_horiz,
                                        color: AppStyles.thirdColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Total a pagar:',
                                      "\$ ${currencyFormatter.format(prestamo['valorTotal']).replaceAll('\$', '')}",),
                                  
                                  _buildInfoRow('Restante:',
                                      "\$ ${currencyFormatter.format(restante).replaceAll('\$', '')}"),
                                  const SizedBox(height: 16),
                                  
                                  _buildLocationRow(prestamo['Cliente']['direccion']),
                                  const SizedBox(height: 8),
                                  _buildPhoneRow(prestamo['Cliente']['telefono']),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          PayModal.showCuotasPayBottomSheet(
                                              context,
                                              prestamo['pagos'],
                                              currencyFormatter.format(prestamo['saldo']),
                                              prestamo['rutaId'],
                                              prestamo['id']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppStyles.thirdColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Ver Cuotas' , style: TextStyle(color: Colors.white),),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No hay clientes disponibles.')),

              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => ClienteForm(
              routeId: widget.routeId,
              interes: widget.interes,
            ),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 500),
          );
        },
        backgroundColor: AppStyles.thirdColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(String? address) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppStyles.thirdColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address != null ? 'Dirección: $address' : 'Dirección no disponible',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

Widget _buildPhoneRow(String? phone) {
  return Row(
    children: [
      const Icon(Icons.phone, color: AppStyles.thirdColor),
      const SizedBox(width: 8),
      Expanded(
        child: GestureDetector(
          onTap: () {
            if (phone != null && phone.isNotEmpty) {
              _makePhoneCall(phone);
            }
          },
          child: Text(
            phone != null ? 'Teléfono: $phone' : 'Teléfono no disponible',
            style: const TextStyle(fontSize: 14, color: Colors.blue),
          ),
        ),
      ),
    ],
  );
}

void _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

}
