import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CashManagementPlatto extends StatefulWidget {
  const CashManagementPlatto({super.key});

  @override
  State<CashManagementPlatto> createState() => _CashManagementPlattoState();
}

class _CashManagementPlattoState extends State<CashManagementPlatto> {
  // Cambia esta URL por la IP de tu servidor si no es local
  final String baseUrl = "http://127.0.0.1:5000";

  // --- FUNCIÓN PARA ENVIAR DATOS (POST) ---
  Future<void> registrarMovimiento(String tipo, double monto) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/movimiento',
        ), // Asegúrate de tener esta ruta en Flask
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "tipo": tipo, // "Ingreso" o "Egreso"
          "monto": monto,
          "fecha": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$tipo registrado correctamente")),
        );
      }
    } catch (e) {
      print("Error al conectar: $e");
    }
  }

  // --- UI ---
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              "Registrar Ingreso",
              Icons.attach_money,
              brandOrange,
              () => _mostrarDialogo("Ingreso"),
            ),
            _buildActionCard(
              "Registrar Egreso",
              Icons.description,
              darkBg,
              () => _mostrarDialogo("Egreso"),
            ),
            _buildActionCard(
              "Conciliación automática",
              Icons.refresh,
              darkBg,
              () => print("Conciliando..."),
            ),
            _buildActionCard(
              "Flujo de efectivo",
              Icons.bar_chart,
              darkBg,
              () => print("Consultando flujo..."),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGO PARA CAPTURAR MONTO ---
  void _mostrarDialogo(String tipo) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Registrar $tipo"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Ingresa el monto"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              registrarMovimiento(tipo, double.parse(controller.text));
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE BOTÓN ---
  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
