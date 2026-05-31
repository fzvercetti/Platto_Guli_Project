import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewOrderPlatto extends StatefulWidget {
  const NewOrderPlatto({super.key});

  @override
  State<NewOrderPlatto> createState() => _NewOrderPlattoState();
}

class _NewOrderPlattoState extends State<NewOrderPlatto> {
  // 1. DATOS ESTÁTICOS (PLAN B)
  final List<dynamic> _productosEstaticos = [
    {"id": 1, "nombre": "Hamburguesa Clásica", "precio": 120},
    {"id": 2, "nombre": "Papas Fritas", "precio": 50},
    {"id": 3, "nombre": "Refresco", "precio": 30},
  ];

  // Variables de estado
  List<dynamic> _productos = [];
  String? _productoSeleccionado;
  String _metodoPago = 'Efectivo';
  final TextEditingController _cantidadController = TextEditingController();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // 2. LÓGICA HÍBRIDA (BD + FALLBACK)
  Future<void> _cargarDatos() async {
    try {
      // Intentamos conectar a Flask (IP 10.0.2.2 es el localhost del emulador Android)
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/productos'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _productos = jsonDecode(response.body);
        });
      } else {
        // Si responde pero no es 200, usamos estáticos
        setState(() => _productos = _productosEstaticos);
      }
    } catch (e) {
      // Si falla la conexión (el servidor está apagado), usamos estáticos
      setState(() => _productos = _productosEstaticos);
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Pedido")),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selecciona el producto:"),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _productos
                        .map(
                          (p) => DropdownMenuItem(
                            value: p['nombre'].toString(),
                            child: Text(p['nombre']),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _productoSeleccionado = val),
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ["Efectivo", "Tarjeta", "Transferencia"]
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => _metodoPago = val!),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        /* Lógica para enviar el pedido */
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
