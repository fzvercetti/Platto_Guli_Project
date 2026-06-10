import 'package:flutter/material.dart';

class AdminSelector extends StatelessWidget {
  const AdminSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Lista estática simulando los datos de tu tabla 'administradores'
    final List<Map<String, dynamic>> administradores = [
      {'id': 1, 'nombre': 'Admin Principal', 'rol': 'Super Admin'},
      {'id': 2, 'nombre': 'Gerencia', 'rol': 'Admin'},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5568),
        title: const Text(
          "Acceso Administrativo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Seleccione su perfil de acceso:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF0E1E40),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: administradores.length,
                itemBuilder: (context, index) {
                  final admin = administradores[index];
                  return InkWell(
                    onTap: () {
                      // Simulación de inicio de sesión
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Acceso concedido: ${admin['nombre']}"),
                          backgroundColor: const Color(0xFFDE7E51),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context); // Regresa al menú principal
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFDE7E51).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFDE7E51,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings, // Ícono más gerencial
                              size: 32,
                              color: Color(0xFFDE7E51),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            admin['nombre'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            admin['rol'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
