import 'package:flutter/material.dart';
import 'sales_platto.dart';

class PlattoMenuPage extends StatelessWidget {
  const PlattoMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta de colores extraída de tu diseño
    const Color orangeColor = Color(0xFFDE7E51);
    const Color slateColor = Color(0xFF6C7486);
    const Color darkBlueText = Color(0xFF0E1E40);

    // Lista con la configuración de cada botón
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'VENTAS',
        'icon': Icons.assignment_outlined,
        'color': orangeColor,
      },
      {
        'title': 'INVENTARIO',
        'icon': Icons.archive_outlined,
        'color': orangeColor,
      },
      {
        'title': 'CAJA/PAGO',
        'icon': Icons.attach_money_rounded,
        'color': orangeColor,
      },
      {
        'title': 'REPORTES',
        'icon': Icons.bar_chart_rounded,
        'color': orangeColor,
      },
      {
        'title': 'USUARIOS',
        'icon': Icons.people_alt_outlined,
        'color': slateColor,
      },
      {
        'title': 'CONFIGURACIÓN',
        'icon': Icons.settings_outlined,
        'color': slateColor,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ENCABEZADO ---
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: orangeColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restaurant, // Ícono de cubiertos
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLATTO',
                        style: TextStyle(
                          color: darkBlueText,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Control total del sabor',
                        style: TextStyle(
                          color: Color(0xFF6C7A9C),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // --- CUADRÍCULA DE BOTONES (GRID) ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // Dos columnas
                  crossAxisSpacing: 16, // Espacio horizontal
                  mainAxisSpacing: 16, // Espacio vertical
                  childAspectRatio:
                      1.0, // Hace que los contenedores sean perfectamente cuadrados
                  children: menuItems.map((item) {
                    return InkWell(
                      onTap: () {
                        if (item['title'] == 'VENTAS') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SalesPlatto(),
                            ),
                          );
                        } else {
                          // Aquí puedes manejar las otras opciones más adelante
                          print('Presionaste: ${item['title']}');
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'], color: Colors.white, size: 55),
                            const SizedBox(height: 12),
                            Text(
                              item['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // --- PIE DE PÁGINA (NOTIFICACIONES) ---
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: darkBlueText.withValues(alpha: 0.8),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: darkBlueText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
