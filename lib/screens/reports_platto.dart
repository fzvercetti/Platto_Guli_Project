import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsPlatto extends StatefulWidget {
  const ReportsPlatto({super.key});

  @override
  State<ReportsPlatto> createState() => _ReportsPlattoState();
}

class _ReportsPlattoState extends State<ReportsPlatto> {
  // Ajusta esta URL a tu localhost o tu enlace activo de tunnelmole/ngrok
  final String baseUrl = "http://127.0.0.1:5000";

  // Paleta de colores de tu diseño
  final Color brandOrange = const Color(0xFFDE7E51);
  final Color darkBlueText = const Color(0xFF0E1E40);
  final Color slateColor = const Color(0xFF6C7486);
  final Color lightGreyBg = const Color(0xFFF5F6F8);
  final Color positiveGreen = const Color(0xFF2E7D32);

  // Variables de estado para los datos de la BD
  bool isLoading = true;
  String ventasTotal = "0";
  String pedidosTotales = "0";
  String clientesTotales = "0";
  String porcentajeVariacion = "+0%";
  List<double> datosGrafica = [0, 0, 0, 0, 0, 0, 0, 0];
  List<dynamic> historialVentas = [];

  @override
  void initState() {
    super.initState();
    _fetchDatosReporte();
  }

  // Conexión al backend para extraer los datos reales de la base de datos
  Future<void> _fetchDatosReporte() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/resumen'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          ventasTotal = data['ventas_hoy'].toString();
          pedidosTotales = data['pedidos_hoy'].toString();
          clientesTotales = data['clientes_hoy'].toString();
          porcentajeVariacion = data['porcentaje_vs_ayer'] ?? "+0%";

          // Mapear alturas de la gráfica desde el backend (valores de 0 a 160 para el diseño)
          if (data['grafica'] != null) {
            datosGrafica = List<double>.from(
              data['grafica'].map((x) => double.parse(x.toString())),
            );
          }

          // Datos de las filas de la tabla inferior
          historialVentas = data['tabla_detalles'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error conectando a la base de datos de reportes: $e");
      // Datos de respaldo para que la interfaz no falle si el servidor está apagado
      setState(() {
        ventasTotal = "12,400";
        pedidosTotales = "124";
        clientesTotales = "98";
        porcentajeVariacion = "+8% vs ayer";
        datosGrafica = [80, 110, 140, 100, 120, 90, 130, 160];
        historialVentas = [
          {"col1": "Reg 1", "col2": "Prod A", "col3": "\$150"},
          {"col1": "Reg 2", "col2": "Prod B", "col3": "\$320"},
          {"col1": "Reg 3", "col2": "Prod C", "col3": "\$90"},
          {"col1": "Reg 4", "col2": "Prod D", "col3": "\$450"},
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: brandOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "PLATTO",
              style: TextStyle(
                color: darkBlueText,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkBlueText),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brandOrange))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, thickness: 1),

                  // --- SECCIÓN 1: MÉTRICAS DESDE BD ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ventas Hoy:",
                          style: TextStyle(
                            fontSize: 16,
                            color: slateColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$$ventasTotal",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: darkBlueText,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.arrow_drop_up, color: positiveGreen),
                                Text(
                                  porcentajeVariacion,
                                  style: TextStyle(
                                    color: positiveGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSubMetric("Pedidos:", pedidosTotales),
                            _buildSubMetric("Clientes:", clientesTotales),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- SECCIÓN 2: GRÁFICA DINÁMICA ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightGreyBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: datosGrafica
                          .map((altura) => _buildBar(altura))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- SECCIÓN 3: TABLA DE DETALLES DESDE BD ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: lightGreyBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: historialVentas
                          .map((item) => _buildTableRow(item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSubMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: slateColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: darkBlueText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: brandOrange,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
    );
  }

  Widget _buildTableRow(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item['col1']?.toString() ?? "",
            style: TextStyle(color: darkBlueText, fontWeight: FontWeight.w500),
          ),
          Text(
            item['col2']?.toString() ?? "",
            style: TextStyle(color: slateColor),
          ),
          Text(
            item['col3']?.toString() ?? "",
            style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
