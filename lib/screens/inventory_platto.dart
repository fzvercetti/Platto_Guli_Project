import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InventoryPlatto extends StatelessWidget {
  const InventoryPlatto({super.key});

  final String apiUrl = "http://127.0.0.1:5000/api/inventario";

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
    const Color brandOrange = Color(0xFFDE7E51);
    const Color darkText = Color(0xFF0E1E40);
    const Color grayCard = Color(0xFF6C7486);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Inventario",
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandOrange),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _statusCard("Stock", Icons.inventory_2, brandOrange, true),
                const SizedBox(width: 10),
                _statusCard("Low", Icons.warning_amber, grayCard, false),
                const SizedBox(width: 10),
                _statusCard("In", Icons.download, grayCard, false),
                const SizedBox(width: 10),
                _statusCard("Out", Icons.upload, grayCard, false),
              ],
            ),
            const SizedBox(height: 25),

            const Row(
              children: [
                Expanded(
                  child: Text(
                    "Product",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Cat.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Stock",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Price",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchInventory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(item['nombre'])),
                            Expanded(child: Text(item['categoria'])),
                            Expanded(child: Text(item['stock'].toString())),
                            Expanded(
                              child: Text("\$${item['precio_unitario']}"),
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
    String title,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
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
