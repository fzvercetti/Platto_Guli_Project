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
        title: const Text(
          "Ventas del Día",
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
            // Aquí irá la lista de ventas (cuando conectes el backend)
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Simulación de 5 ventas
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.receipt_long,
                        color: brandOrange,
                      ),
                      title: Text(
                        "Pedido #${100 + index}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text("Total: \$450.00"),
                      trailing: const Text(
                        "14:30",
                        style: TextStyle(color: Colors.grey),
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
