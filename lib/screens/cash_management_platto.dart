import 'package:flutter/material.dart';

class CashManagementPlatto extends StatelessWidget {
  const CashManagementPlatto({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFDE7E51);
    const Color darkBg = Color(0xFF0E1E40);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Caja/Pago",
          style: TextStyle(color: darkBg, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandOrange),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: darkBg),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: darkBg),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              "Registrar Ingreso",
              Icons.attach_money,
              brandOrange,
              context,
            ),
            _buildActionCard(
              "Registrar Egreso",
              Icons.description,
              darkBg,
              context,
            ),
            _buildActionCard(
              "Conciliación automática",
              Icons.refresh,
              darkBg,
              context,
            ),
            _buildActionCard(
              "Flujo de efectivo",
              Icons.bar_chart,
              darkBg,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        // Aquí agregarás la navegación a cada funcionalidad
        print("Acción: $title");
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
