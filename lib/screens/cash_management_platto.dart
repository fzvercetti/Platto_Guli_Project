import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en tu pubspec.yaml
import 'conciliation_platto.dart';

class CashManagementPlatto extends StatefulWidget {
  const CashManagementPlatto({super.key});

  @override
  State<CashManagementPlatto> createState() => _CashManagementPlattoState();
}

class _CashManagementPlattoState extends State<CashManagementPlatto> {
  // Cambia esta URL por la IP de tu servidor si no es local o tu enlace de túnel
  final String baseUrl = "http://127.0.0.1:5000";

  // --- FUNCIÓN PARA ENVIAR DATOS (POST) ---
  // Ahora recibe también el concepto
  Future<void> registrarMovimiento(
    String tipo,
    double monto,
    String concepto,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/movimiento',
        ), // Ajusta la ruta a tu API de Flask
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "tipo": tipo, // "Ingreso" o "Egreso"
          "monto": monto,
          "concepto": concepto, // Nuevo campo enviado a la base de datos
          "fecha": DateTime.now().toIso8601String(), // Hora y fecha automática
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$tipo registrado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error al conectar: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al conectar con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
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
          "Caja / Pagos",
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
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConciliationPlatto(),
                  ),
                );
              },
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

  // --- DIÁLOGO PARA CAPTURAR MONTO Y CONCEPTO ---
  void _mostrarDialogo(String tipo) {
    TextEditingController montoController = TextEditingController();
    TextEditingController conceptoController = TextEditingController();

    // Generamos un texto amigable para mostrar la fecha/hora automática en la UI
    String fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Registrar $tipo",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Evita que ocupe toda la pantalla
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de Monto
            TextField(
              controller: montoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Cantidad / Monto",
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de Concepto
            TextField(
              controller: conceptoController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: "Concepto",
                hintText: tipo == "Ingreso"
                    ? "Ej. Venta externa, Propina"
                    : "Ej. Pago a proveedor, Luz",
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Indicador visual de la fecha automática
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Fecha y hora: $fechaFormateada\n(Se registrará automáticamente)",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tipo == "Ingreso"
                  ? const Color(0xFFDE7E51)
                  : const Color(0xFF0E1E40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Validar que no envíen campos vacíos
              if (montoController.text.isEmpty ||
                  conceptoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Por favor llena todos los campos"),
                  ),
                );
                return;
              }

              registrarMovimiento(
                tipo,
                double.parse(montoController.text),
                conceptoController.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
