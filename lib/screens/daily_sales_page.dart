import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Definimos el color aquí también para evitar errores
const Color orangeColor = Color(0xFFE98A5C);

class DailySalesPage extends StatefulWidget {
  const DailySalesPage({super.key});

  @override
  State<DailySalesPage> createState() => _DailySalesPageState();
}

class _DailySalesPageState extends State<DailySalesPage> {
  // 1. DATOS ESTÁTICOS (PLAN B)
  List<dynamic> _ventas = [
    {"id": 1, "total": 250.0, "metodo": "Efectivo"},
    {"id": 2, "total": 400.0, "metodo": "Tarjeta"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchVentasFromAPI(); // Cargamos en segundo plano
  }

  Future<void> _fetchVentasFromAPI() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:5000/api/ventas_dia'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _ventas = jsonDecode(response.body);
          });
        }
      }
    } catch (e) {
      // Si falla, simplemente no hacemos nada. El usuario sigue viendo los datos estáticos.
      debugPrint("No se pudo conectar a la BD para ventas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas del día"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _ventas.isEmpty
          ? const Center(child: Text("No hay ventas registradas hoy"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ventas.length,
              itemBuilder: (context, index) {
                final venta = _ventas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: orangeColor,
                      child: Icon(Icons.attach_money, color: Colors.white),
                    ),
                    title: Text("Venta #${venta['id'] ?? index + 1}"),
                    subtitle: Text("Método: ${venta['metodo']}"),
                    trailing: Text(
                      "\$${venta['total']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
