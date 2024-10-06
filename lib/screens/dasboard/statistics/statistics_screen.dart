import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Para los gráficos circulares y de barras.

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Control Empresarial'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDoubleColumnCard(
              title1: 'Total Prestado',
              value1: '\$120,000',
              icon1: Icons.attach_money,
              title2: 'Total a Pagar',
              value2: '\$150,000',
              icon2: Icons.payment,
            ),
            SizedBox(height: 16),
            _buildDoubleColumnCard(
              title1: 'Clientes Activos',
              value1: '300',
              icon1: Icons.group,
              title2: 'Préstamos Activos',
              value2: '120',
              icon2: Icons.credit_card,
            ),
            SizedBox(height: 16),
            _buildListCard('Próximos Pagos', Icons.calendar_today, _buildUpcomingPaymentsList()),
            SizedBox(height: 16),
            _buildChartCard('Préstamos por Estado', Icons.pie_chart, _buildPieChart()),
            SizedBox(height: 16),
            _buildChartCard('Monto Prestado por Cliente', Icons.bar_chart, _buildBarChart()),
            SizedBox(height: 16),
            _buildListCard('Clientes con Deudas Pendientes', Icons.warning, _buildPendingClientsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleColumnCard({required String title1, required String value1, required IconData icon1, required String title2, required String value2, required IconData icon2}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColumnItem(title1, value1, icon1),
            VerticalDivider(),
            _buildColumnItem(title2, value2, icon2),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.blue),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 24, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildListCard(String title, IconData icon, Widget content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.blue),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPaymentsList() {
    // Lista simulada de próximos pagos
    return const Column(
      children: [
        ListTile(
          leading: Icon(Icons.attach_money),
          title: Text('Cliente 1'),
          subtitle: Text('Pago: \$500'),
          trailing: Text('05/10/2024'),
        ),
        ListTile(
          leading: Icon(Icons.attach_money),
          title: Text('Cliente 2'),
          subtitle: Text('Pago: \$750'),
          trailing: Text('06/10/2024'),
        ),
        // Añadir más pagos según sea necesario
      ],
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(color: Colors.green, value: 40, title: 'Aprobado'),
            PieChartSectionData(color: Colors.red, value: 30, title: 'Rechazado'),
            PieChartSectionData(color: Colors.orange, value: 20, title: 'Pendiente'),
            PieChartSectionData(color: Colors.blue, value: 10, title: 'Otro'),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 8, fromY: 0, color: Colors.blue)],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: 10, fromY: 0, color: Colors.blue)],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 6, fromY: 0, color: Colors.blue)],
              showingTooltipIndicators: [0],
            ),
            // Añadir más barras según sea necesario
          ],
        ),
      ),
    );
  }

  Widget _buildPendingClientsList() {
    // Lista simulada de clientes con deudas pendientes
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Cliente A'),
          subtitle: Text('Deuda: \$1,200'),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Cliente B'),
          subtitle: Text('Deuda: \$950'),
        ),
        // Añadir más clientes según sea necesario
      ],
    );
  }

  Widget _buildChartCard(String title, IconData icon, Widget chart) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.blue),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: chart,
          ),
        ],
      ),
    );
  }
}
