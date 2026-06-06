import 'package:flutter/material.dart';
import '../utils/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color orangeColor = Color(0xFFE98A5C);

class NewOrderPlatto extends StatefulWidget {
  const NewOrderPlatto({super.key});

  @override
  State<NewOrderPlatto> createState() => _NewOrderPlattoState();
}

class _NewOrderPlattoState extends State<NewOrderPlatto> {
  List<dynamic> _productos = [];
  String? _productoSeleccionado;
  String _metodoPago = 'Efectivo';
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductosFromAPI();
  }

  Future<void> _fetchProductosFromAPI() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/productos/productos'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _productos = jsonDecode(response.body);
          });
        }
      }
    } catch (e) {
      debugPrint("No se pudo conectar a la BD: $e");
    }
  }

  Future<void> _savePedido() async {
    if (_productoSeleccionado == null || _cantidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona producto y cantidad")),
      );
      return;
    }

    final producto = _productos.firstWhere(
      (p) => p['nombre'] == _productoSeleccionado,
    );
    final int productId = (producto['id'] as num).toInt();
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/pedido/pedido'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "producto_id": productId,
          "cantidad": cantidad,
          "metodo_pago": _metodoPago,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Pedido guardado con éxito!")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error al guardar: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Pedido")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Producto:"),
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
              decoration: const InputDecoration(border: OutlineInputBorder()),
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
              ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _metodoPago = val!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    _savePedido, // <--- Aquí ya está conectada la función
                child: const Text(
                  "Confirmar Pedido",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
