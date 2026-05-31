import 'package:flutter/material.dart';
import 'sales_platto.dart';
import 'inventory_platto.dart';
import 'cash_management_platto.dart';
import 'reports_platto.dart';
import 'settings_screen.dart';

class PlattoMenuPage extends StatelessWidget {
  const PlattoMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos si estamos en modo oscuro
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Paleta de marca (Estos se mantienen igual porque son los colores de tu logo/botones)
    const Color orangeColor = Color(0xFFDE7E51);
    const Color slateColor = Color(0xFF6C7486);

    // Colores dinámicos para el texto
    final Color titleColor = isDarkMode
        ? Colors.white
        : const Color(0xFF0E1E40);
    final Color subtitleColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF6C7A9C);

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
      // Usamos el color de fondo definido en el Tema global
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      Icons.restaurant,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLATTO',
                        style: TextStyle(
                          color: titleColor, // Color dinámico
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Control total del sabor',
                        style: TextStyle(
                          color: subtitleColor, // Color dinámico
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // --- CUADRÍCULA DE BOTONES ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: menuItems.map((item) {
                    return InkWell(
                      onTap: () {
                        // Navegación (sin cambios)
                        if (item['title'] == 'VENTAS') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalesPlatto(),
                            ),
                          );
                        } else if (item['title'] == 'INVENTARIO') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InventoryPlatto(),
                            ),
                          );
                        } else if (item['title'] == 'CAJA/PAGO') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CashManagementPlatto(),
                            ),
                          );
                        } else if (item['title'] == 'REPORTES') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportsPlatto(),
                            ),
                          );
                        } else if (item['title'] == 'CONFIGURACIÓN') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              // Sombra sutil que se adapta
                              color: isDarkMode
                                  ? Colors.black54
                                  : Colors.black.withValues(alpha: 0.05),
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
                            const Text(
                              // No toco el título porque siempre es blanco sobre fondo naranja
                              '',
                              style: TextStyle(color: Colors.white),
                            ),
                            // Reemplazo la lógica de texto de abajo para asegurar legibilidad
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

              // --- PIE DE PÁGINA ---
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
