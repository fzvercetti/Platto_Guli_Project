import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:platto_app/utils/api_config.dart';

class InventoryPlatto extends StatelessWidget {
  const InventoryPlatto({super.key});

  final String apiUrl = "${ApiConfig.baseUrl}/api/productos/inventario";

  Future<List<dynamic>> fetchInventory() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar inventory');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos colores de marca que SI queremos mantener fijos
    const Color brandOrange = Color(0xFFDE7E51);

    // Obtenemos el estilo de texto global del tema
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Inventario",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandOrange),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Cards
            Row(
              children: [
                _statusCard(
                  context,
                  "Stock",
                  Icons.inventory_2,
                  brandOrange,
                  true,
                ),
                const SizedBox(width: 10),
                _statusCard(
                  context,
                  "Bajo",
                  Icons.warning_amber,
                  Colors.grey,
                  false,
                ),
                const SizedBox(width: 10),
                _statusCard(context, "In", Icons.download, Colors.grey, false),
                const SizedBox(width: 10),
                _statusCard(context, "Out", Icons.upload, Colors.grey, false),
              ],
            ),
            const SizedBox(height: 25),

            // Headers de la tabla
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Productos",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textStyle.bodyMedium?.color,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Categoria.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textStyle.bodyMedium?.color,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Stock",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textStyle.bodyMedium?.color,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Precio",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textStyle.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
            Divider(thickness: 2, color: Theme.of(context).dividerColor),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchInventory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // Usamos estilos por defecto del tema para asegurar legibilidad
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(item['nombre'] ?? '-')),
                            Expanded(child: Text(item['categoria'] ?? '-')),
                            Expanded(
                              child: Text(item['stock']?.toString() ?? '0'),
                            ),
                            Expanded(
                              child: Text(
                                "\$${item['precio_unitario'] ?? '0'}",
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    // Ajustamos la opacidad del fondo para modo oscuro si es necesario
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : color.withValues(alpha: isDarkMode ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
