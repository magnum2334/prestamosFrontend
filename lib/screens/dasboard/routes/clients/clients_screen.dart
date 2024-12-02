import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stikev/getX/ClienteCrontroller.dart';
import 'package:stikev/getX/LoginController.dart';
import 'package:stikev/screens/dasboard/routes/clients/form_client_sreem.dart';
import 'package:stikev/screens/dasboard/routes/clients/widget/pay_modal.dart';
import 'package:stikev/utils/animated_icon.dart';
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
  // ignore: library_private_types_in_public_api
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final LoginController loginController = Get.put(LoginController());
  final ClientesController clientesController = Get.put(ClientesController());
  List<dynamic> prestamos = [];
  List<dynamic> filteredPrestamos = [];
  bool isLoading = true;
  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'es_ES', symbol: '\$', decimalDigits: 0);

  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the prestamos initially
    clientesController.fetchPrestamos(
      AppConfig.rutaPrestamoApiUrl(widget.routeId.toString()),
      loginController.token.value,
    );

    // Initialize filteredPrestamos with all prestamos
    filteredPrestamos = clientesController.prestamos;
  }

  void filterPrestamos() {
    String nameQuery = nameController.text.toLowerCase();

    setState(() {
      filteredPrestamos = clientesController.prestamos.where((prestamo) {
        String clientName = prestamo['Cliente']['nombre'].toLowerCase();
        return clientName.contains(nameQuery);
      }).toList();
    });
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: nameController,
              onChanged: (value) => filterPrestamos(),
              decoration: InputDecoration(
                labelStyle: const TextStyle(color: AppStyles.thirdColor),
                hintText: 'Ingresa el nombre del cliente',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: AppStyles.thirdColor),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
              ),
            ),
          ),
        ),
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
                child: Column(
                  children: [
                    Expanded(
                      child: filteredPrestamos.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.all(24.0),
                              itemCount: filteredPrestamos.length,
                              itemBuilder: (context, index) {
                                final prestamo = filteredPrestamos[index];
                                Widget iconStatus =
                                    (prestamo['estado'].trim() == 'Mora')
                                        ? AnimatedIconWidget(iconColor: Colors.orange,)
                                        : const Icon(Icons.star,
                                            color: Colors.green);
                                // Calcular el valor abonado
                                final abonado = prestamo['saldo'];

                                // Calcular el valor restante
                                final restante =
                                    prestamo['valorTotal'] - abonado;

                                return Card(
                                  color: Colors.white,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  'Código: KAC-${prestamo['id']}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppStyles.thirdColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  prestamo['estado'].trim(),
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 19,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                iconStatus,
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoRow('Total a pagar:',
                                            "\$ ${currencyFormatter.format(prestamo['valorTotal']).replaceAll('\$', '')}"),
                                        _buildInfoRow('Valor prestado:',
                                            "\$ ${currencyFormatter.format(prestamo['valorPrestado']).replaceAll('\$', '')}"),
                                        const SizedBox(height: 8),
                                        _buildInfoRow('Restante:',
                                            "\$ ${currencyFormatter.format(restante).replaceAll('\$', '')}"),
                                        const SizedBox(height: 16),
                                        _buildTimeRow(prestamo['frecuencia']),
                                        const SizedBox(height: 8),
                                        _buildLocationRow(
                                            prestamo['Cliente']['direccion']),
                                        const SizedBox(height: 8),
                                        _buildPhoneRow(
                                            prestamo['Cliente']['telefono']),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                PayModal
                                                    .showCuotasPayBottomSheet(
                                                        context,
                                                        currencyFormatter
                                                            .format(restante),
                                                        prestamo);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppStyles.thirdColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('Ver Cuotas',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No hay clientes disponibles.')),
                    ),
                  ],
                ),
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
            color: Colors.green,
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

  Widget _buildTimeRow(String? frecuencia) {
    return Row(
      children: [
        const Icon(Icons.calendar_month, color: AppStyles.thirdColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            frecuencia != null
                ? 'Frecuencia de pago: $frecuencia'
                : 'Frecuencia no disponible',
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }
}
