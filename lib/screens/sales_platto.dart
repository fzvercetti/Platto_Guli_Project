import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importa tu pantalla de reportes. Asegúrate de que la ruta sea correcta.
import 'reports_platto.dart';

class SalesPlatto extends StatelessWidget {
  const SalesPlatto({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFDE7E51);
    const Color darkText = Color(0xFF0E1E40);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandOrange),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo y Título
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.restaurant, size: 50, color: brandOrange),
            ),
            const SizedBox(height: 10),
            const Text(
              "PLATTO",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const Text(
              "Control total del sabor",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // --- BOTONES DEL DASHBOARD ---
            _buildMenuButton("Nuevo Pedido", Icons.add, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewOrderScreen()),
              );
            }),
            _buildMenuButton("Ver Ventas Del Día", Icons.receipt_long, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailySalesScreen(),
                ),
              );
            }),
            _buildMenuButton("Resumen Semanal/Mensual", Icons.trending_up, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPlatto()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDE7E51),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PANTALLA 1: NUEVO PEDIDO (CONECTADA A BD)
// ============================================================================
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  // Ajusta esta base URL a tu localhost o tu enlace de tunnelmole
  final String baseUrl = "http://127.0.0.1:5000";

  List<dynamic> productos = [];
  String? productoSeleccionado;

  // Lista de métodos de pago (podrían venir de la BD también, aquí están fijos para el ejemplo)
  final List<String> metodosPago = ['Efectivo', 'Tarjeta'];
  String metodoSeleccionado = 'Efectivo';

  final TextEditingController cantidadController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  // Extraer productos de la base de datos
  Future<void> _fetchProductos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/productos'));
      if (response.statusCode == 200) {
        setState(() {
          productos = json.decode(
            response.body,
          ); // Asume un JSON como: [{"id": 1, "nombre": "Hamburguesa"}, ...]
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error obteniendo productos: $e");
      // Datos de prueba en caso de que el backend no esté corriendo
      setState(() {
        productos = [
          {"id": 1, "nombre": "Hamburguesa Clásica"},
          {"id": 2, "nombre": "Papas Fritas"},
          {"id": 3, "nombre": "Refresco"},
        ];
        isLoading = false;
      });
    }
  }

  // Enviar el pedido a la base de datos
  Future<void> _guardarPedido() async {
    if (productoSeleccionado == null || cantidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pedido'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "producto_id": productoSeleccionado,
          "cantidad": int.parse(cantidadController.text),
          "metodo_pago": metodoSeleccionado,
          "fecha": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido registrado con éxito")),
        );
        Navigator.pop(context); // Regresar al menú
      }
    } catch (e) {
      print("Error guardando pedido: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFDE7E51);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Nuevo Pedido",
          style: TextStyle(color: Color(0xFF0E1E40)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: brandOrange),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: brandOrange))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selecciona el producto:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: productoSeleccionado,
                    hint: const Text("Elegir producto"),
                    items: productos.map((producto) {
                      return DropdownMenuItem<String>(
                        value: producto['id'].toString(),
                        child: Text(producto['nombre']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => productoSeleccionado = value),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Cantidad:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Ej. 2",
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Método de Pago:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: metodoSeleccionado,
                    items: metodosPago.map((metodo) {
                      return DropdownMenuItem<String>(
                        value: metodo,
                        child: Text(metodo),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => metodoSeleccionado = value!),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _guardarPedido,
                      child: const Text(
                        "Confirmar Pedido",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================================
// PANTALLA 2: VER VENTAS DEL DÍA (CONECTADA A BD)
// ============================================================================
class DailySalesScreen extends StatefulWidget {
  const DailySalesScreen({super.key});

  @override
  State<DailySalesScreen> createState() => _DailySalesScreenState();
}

class _DailySalesScreenState extends State<DailySalesScreen> {
  final String baseUrl = "http://127.0.0.1:5000";
  List<dynamic> ventasHoy = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVentasDia();
  }

  Future<void> _fetchVentasDia() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/ventas/hoy'));
      if (response.statusCode == 200) {
        setState(() {
          ventasHoy = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      // Datos de prueba para previsualización
      setState(() {
        ventasHoy = [
          {
            "id": 101,
            "producto": "Hamburguesa Clásica",
            "total": 120.00,
            "metodo": "Tarjeta",
          },
          {
            "id": 102,
            "producto": "Papas Fritas",
            "total": 45.00,
            "metodo": "Efectivo",
          },
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFDE7E51);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Ventas del Día",
          style: TextStyle(color: Color(0xFF0E1E40)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: brandOrange),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: brandOrange))
          : ventasHoy.isEmpty
          ? const Center(child: Text("No hay ventas registradas hoy"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ventasHoy.length,
              itemBuilder: (context, index) {
                final venta = ventasHoy[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: brandOrange.withValues(alpha: 0.2),
                      child: const Icon(Icons.receipt, color: brandOrange),
                    ),
                    title: Text(
                      "Pedido #${venta['id']} - ${venta['producto']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Método: ${venta['metodo']}"),
                    trailing: Text(
                      "\$${venta['total']}",
                      style: const TextStyle(
                        color: Colors.green,
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
