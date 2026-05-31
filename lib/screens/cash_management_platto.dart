import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'conciliation_platto.dart';
import 'cash_flow_platto.dart';

class CashManagementPlatto extends StatefulWidget {
  const CashManagementPlatto({super.key});

  @override
  State<CashManagementPlatto> createState() => _CashManagementPlattoState();
}

class _CashManagementPlattoState extends State<CashManagementPlatto> {
  final String baseUrl = "http://127.0.0.1:5000";

  Future<void> registrarMovimiento(
    String tipo,
    double monto,
    String concepto,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/movimiento'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "tipo": tipo,
          "monto": monto,
          "concepto": concepto,
          "fecha": DateTime.now().toIso8601String(),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al conectar con el servidor"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detectar tema para colores dinámicos
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Colores de marca
    const Color brandOrange = Color(0xFFDE7E51);
    const Color darkBg = Color(0xFF0E1E40);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Caja / Pagos",
          style: TextStyle(
            color: isDarkMode ? Colors.white : darkBg,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            _buildActionCard("Flujo de efectivo", Icons.bar_chart, darkBg, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CashFlowPlatto()),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogo(String tipo) {
    TextEditingController montoController = TextEditingController();
    TextEditingController conceptoController = TextEditingController();

    // Para que los inputs del diálogo se vean bien en modo oscuro
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[50],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Registrar $tipo",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: montoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: inputDecoration.copyWith(
                labelText: "Cantidad / Monto",
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: conceptoController,
              decoration: inputDecoration.copyWith(
                labelText: "Concepto",
                hintText: tipo == "Ingreso"
                    ? "Ej. Venta, Propina"
                    : "Ej. Proveedor, Luz",
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tipo == "Ingreso"
                  ? const Color(0xFFDE7E51)
                  : const Color(0xFF0E1E40),
            ),
            onPressed: () {
              if (montoController.text.isNotEmpty &&
                  conceptoController.text.isNotEmpty) {
                registrarMovimiento(
                  tipo,
                  double.parse(montoController.text),
                  conceptoController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
