import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:platto_app/utils/api_config.dart';

class ReportsPlatto extends StatefulWidget {
  const ReportsPlatto({super.key});

  @override
  State<ReportsPlatto> createState() => _ReportsPlattoState();
}

class _ReportsPlattoState extends State<ReportsPlatto> {
  final String baseUrl = ApiConfig.baseUrl;
  final Color brandOrange = const Color(0xFFDE7E51);
  final Color positiveGreen = const Color(0xFF2E7D32);

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

  Future<void> _fetchDatosReporte() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/resumen/resumen'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          ventasTotal = data['ventas_hoy'].toString();
          pedidosTotales = data['pedidos_hoy'].toString();
          clientesTotales = data['clientes_hoy'].toString();
          porcentajeVariacion = data['porcentaje_vs_ayer'] ?? "+0%";
          if (data['grafica'] != null) {
            datosGrafica = List<double>.from(
              data['grafica'].map((x) => double.parse(x.toString())),
            );
          }
          historialVentas = data['tabla_detalles'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        ventasTotal = "12,400";
        pedidosTotales = "124";
        clientesTotales = "98";
        porcentajeVariacion = "+8% vs ayer";
        datosGrafica = [80, 110, 140, 100, 120, 90, 130, 160];
        historialVentas = [
          {"col1": "Reg 1", "col2": "Prod A", "col3": "\$150"},
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF0E1E40);
    final Color secondaryTextColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF6C7486);
    final Color cardBg = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                color: textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brandOrange))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ventas Hoy:",
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor,
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
                                color: textColor,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.arrow_drop_up, color: positiveGreen),
                                Text(
                                  porcentajeVariacion,
                                  style: const TextStyle(
                                    color: Colors.green,
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
                          children: [
                            _buildSubMetric(
                              "Pedidos:",
                              pedidosTotales,
                              textColor,
                              secondaryTextColor,
                            ),
                            const SizedBox(width: 40),
                            _buildSubMetric(
                              "Clientes:",
                              clientesTotales,
                              textColor,
                              secondaryTextColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: historialVentas
                          .map(
                            (item) => _buildTableRow(
                              item,
                              textColor,
                              secondaryTextColor,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSubMetric(
    String label,
    String value,
    Color textColor,
    Color secondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: secondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
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

  Widget _buildTableRow(dynamic item, Color textColor, Color secondaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item['col1']?.toString() ?? "",
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
          Text(
            item['col2']?.toString() ?? "",
            style: TextStyle(color: secondaryColor),
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
