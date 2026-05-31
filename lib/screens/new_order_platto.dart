import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewOrderPlatto extends StatefulWidget {
  const NewOrderPlatto({super.key});

  @override
  State<NewOrderPlatto> createState() => _NewOrderPlattoState();
}

class _NewOrderPlattoState extends State<NewOrderPlatto> {
  // 1. DATOS ESTÁTICOS (PLAN B) - Cargan instantáneamente
  List<dynamic> _productos = [
    {"id": 1, "nombre": "Hamburguesa Clásica", "precio": 120.0},
    {"id": 2, "nombre": "Papas Fritas", "precio": 50.0},
    {"id": 3, "nombre": "Refresco", "precio": 30.0},
  ];

  String? _productoSeleccionado;
  String _metodoPago = 'Efectivo';
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 2. Intentamos conectar a la BD en segundo plano sin bloquear la UI
    _fetchProductosFromAPI();
  }

  Future<void> _fetchProductosFromAPI() async {
    try {
      // Intentamos conectar a Flask. Le damos 5 segundos de espera máximo.
      final response = await http
          .get(Uri.parse('http://localhost:5000/api/productos'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Si el servidor responde, actualizamos la lista real
        if (mounted) {
          setState(() {
            _productos = jsonDecode(response.body);
          });
        }
      }
    } catch (e) {
      // Si falla, no hacemos nada. El usuario ya está viendo los datos estáticos.
      debugPrint("No se pudo conectar a la BD: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Pedido"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Selecciona el producto:"),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _productos
                  .map(
                    (p) => DropdownMenuItem(
                      value: p['nombre'].toString(),
                      child: Text("${p['nombre']} - \$${p['precio']}"),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _productoSeleccionado = val),
            ),
            const SizedBox(height: 20),

            const Text("Cantidad:"),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                hintText: "Ej. 2",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            const Text("Método de Pago:"),
            DropdownButtonFormField<String>(
              value: _metodoPago,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                "Efectivo",
                "Tarjeta",
                "Transferencia",
              ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _metodoPago = val!),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí iría tu lógica de guardado
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pedido procesado")),
                  );
                },
                child: const Text("Confirmar Pedido"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
