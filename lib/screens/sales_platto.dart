import 'package:flutter/material.dart';
import 'new_order_platto.dart';
import 'daily_sales_page.dart';
import 'summary_page.dart';

const Color orangeColor = Color(0xFFE98A5C);

class SalesPlatto extends StatelessWidget {
  const SalesPlatto({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dynamicBg = Theme.of(context).scaffoldBackgroundColor;
    final Color dynamicText = isDark ? Colors.white : const Color(0xFF1A2639);
    final Color dynamicSubText = isDark
        ? Colors.grey.shade400
        : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: dynamicBg,
      // --- AQUÍ AÑADIMOS EL APPBAR PARA EL BOTÓN DE REGRESO ---
      appBar: AppBar(
        backgroundColor: dynamicBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: orangeColor),
          onPressed: () =>
              Navigator.pop(context), // Esto regresa a la pantalla anterior
        ),
      ),
      // --------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 20.0,
          ), // Ajusté un poco el padding vertical
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: orangeColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PLATTO",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: dynamicText,
                        ),
                      ),
                      Text(
                        "Control total del sabor",
                        style: TextStyle(fontSize: 15, color: dynamicSubText),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 70),
              _buildMenuButton(Icons.add, "Nuevo Pedido", dynamicText, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewOrderPlatto(),
                  ),
                );
              }),
              const SizedBox(height: 20),
              _buildMenuButton(
                Icons.assignment_outlined,
                "Ver Ventas Del Día",
                dynamicText,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DailySalesPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                Icons.trending_up,
                "Resumen Semanal/Mensual",
                dynamicText,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SummaryPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    IconData icon,
    String label,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 68,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
