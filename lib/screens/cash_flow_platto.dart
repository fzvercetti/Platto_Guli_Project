import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CashFlowPlatto extends StatefulWidget {
  const CashFlowPlatto({super.key});

  @override
  State<CashFlowPlatto> createState() => _CashFlowPlattoState();
}

class _CashFlowPlattoState extends State<CashFlowPlatto> {
  // Configuración de red (Ajustar IP según dispositivo)
  final String baseUrl = "http://10.0.2.2:5000";

  bool isLoading = true;
  double netBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  List<Map<String, dynamic>> movements = [];

  @override
  void initState() {
    super.initState();
    //Load Static Data Firts
    _loadStaticData();

    _fetchCashFlow();
  }

  // --- Lógica: Conexión a BD con respaldo estático ---
  Future<void> _fetchCashFlow() async {
    try {
      // Un timeout más corto para que falle rápido si no hay servidor
      final response = await http
          .get(Uri.parse("$baseUrl/api/cash/flow"))
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Solo actualizamos si el widget sigue vivo
        if (!mounted) return;

        setState(() {
          movements = List<Map<String, dynamic>>.from(data['movements']);
          netBalance = data['net_balance'].toDouble();
          totalIncome = data['total_income'].toDouble();
          totalExpenses = data['total_expenses'].toDouble();
          // isLoading ya es false porque _loadStaticData ya lo puso así
        });
      }
    } catch (e) {
      // Si falla, no hacemos nada, dejamos los datos estáticos que ya cargaron
      debugPrint("Servidor no disponible, manteniendo datos estáticos.");
    }
  }

  void _loadStaticData() {
    setState(() {
      netBalance = 2500.00;
      totalIncome = 2820.00;
      totalExpenses = 320.00;
      movements = [
        {
          "description": "Venta - Mesa 7",
          "time": "09:30",
          "payment_method": "Efectivo",
          "amount": 650.00,
          "type": "income",
        },
        {
          "description": "Venta - Mesa 3",
          "time": "10:15",
          "payment_method": "Tarjeta",
          "amount": 420.00,
          "type": "income",
        },
        {
          "description": "Compra Verduras",
          "time": "11:00",
          "payment_method": "Efectivo",
          "amount": 120.00,
          "type": "expense",
        },
        {
          "description": "Venta - Mesa 2",
          "time": "14:20",
          "payment_method": "Tarjeta",
          "amount": 390.00,
          "type": "income",
        },
        {
          "description": "Venta - Mesa 8",
          "time": "15:00",
          "payment_method": "Efectivo",
          "amount": 780.00,
          "type": "income",
        },
      ];
      isLoading = false;
    });
  }

  // --- Lógica: Generación de PDF ---
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Header(level: 0, child: pw.Text("Reporte de Flujo de Efectivo")),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                ['Concepto', 'Hora', 'Metodo', 'Monto'],
                ...movements.map(
                  (m) => [
                    m['description'],
                    m['time'],
                    m['payment_method'],
                    "${m['type'] == 'income' ? '+' : '-'}\$${m['amount']}",
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Esta opción abre el menú de compartir del sistema (permite guardar en archivos)
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'reporte_flujo_efectivo.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          "Detalle de Flujo de Efectivo",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A5568),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A5568),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Balance Neto",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "\$${netBalance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ingresos: +\$${totalIncome.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                          Text(
                            "Egresos: -\$${totalExpenses.toStringAsFixed(2)}",
                            style: const TextStyle(color: Color(0xFFFC8181)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final item = movements[index];
                      bool isIncome = item['type'] == 'income';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isIncome
                                ? Icons.account_balance_wallet
                                : Icons.shopping_bag_outlined,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            item['description'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${item['time']} • ${item['payment_method']}",
                          ),
                          trailing: Text(
                            "${isIncome ? '+' : '-'}\$${item['amount'].toStringAsFixed(2)}",
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Botón PDF
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDE7E51),
                      ),
                      onPressed: _generatePdf,
                      child: const Text(
                        "GENERAR REPORTE PDF",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
