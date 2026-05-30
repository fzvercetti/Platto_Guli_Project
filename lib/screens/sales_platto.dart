import 'package:flutter/material.dart';

class SalesPlatto extends StatelessWidget {
  const SalesPlatto({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFDE7E51);
    const Color darkText = Color(0xFF0E1E40);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandOrange),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo y Título
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.restaurant, size: 50, color: brandOrange),
            ),
            const SizedBox(height: 10),
            const Text(
              "PLATTO",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const Text(
              "Control total del sabor",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // --- BOTONES DEL DASHBOARD ---
            _buildMenuButton("Nuevo Pedido", Icons.add, () {
              // Navegar a pantalla de Nueva Venta
            }),
            _buildMenuButton("Ver Ventas Del Día", Icons.receipt_long, () {
              // Navegar a la lista de ventas (puedes reutilizar la lógica anterior)
            }),
            _buildMenuButton("Resumen Semanal/Mensual", Icons.trending_up, () {
              // Navegar a reportes
            }),
            _buildMenuButton("Método de Pago", Icons.payment, () {
              // Configuración de pagos
            }),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los botones grandes
  Widget _buildMenuButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDE7E51),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 20),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
