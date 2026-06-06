import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import '../utils/api_config.dart';

class CashFlowPlatto extends StatefulWidget {
  const CashFlowPlatto({super.key});

  @override
  State<CashFlowPlatto> createState() => _CashFlowPlattoState();
}

class _CashFlowPlattoState extends State<CashFlowPlatto> {
<<<<<<< HEAD
  final String baseUrl = ApiConfig.baseUrl;
=======
  final String baseUrl = "http://127.0.0.1:5000/api/ventas";
>>>>>>> c09d00064163c8a51069397f84a6175097086b63
  bool isLoading = true;
  double netBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  List<Map<String, dynamic>> movements = [];

  @override
  void initState() {
    super.initState();
    _fetchCashFlow();
  }

  // --- LÓGICA DE DATOS Y CONEXIÓN ---

  void _loadStaticData() {
    setState(() {
      netBalance = 2450.75;
      totalIncome = 5100.00;
      totalExpenses = 2649.25;
      movements = [
        {
          "description": "Venta Hamburguesa Clásica",
          "type": "income",
          "amount": 150.0,
          "time": "10:30 AM",
          "payment_method": "Tarjeta",
        },
        {
          "description": "Compra Insumos (Lechuga)",
          "type": "expense",
          "amount": 450.0,
          "time": "11:15 AM",
          "payment_method": "Efectivo",
        },
        {
          "description": "Venta Especial del Día",
          "type": "income",
          "amount": 320.0,
          "time": "13:00 PM",
          "payment_method": "Tarjeta",
        },
        {
          "description": "Pago Servicio Gas",
          "type": "expense",
          "amount": 1200.0,
          "time": "15:45 PM",
          "payment_method": "Transferencia",
        },
      ];
      isLoading = false;
    });
  }

  Future<void> _fetchCashFlow() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/cashflow'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          netBalance = double.tryParse(data['neto']?.toString() ?? '0') ?? 0.0;
          totalIncome =
              double.tryParse(data['ingresos']?.toString() ?? '0') ?? 0.0;
          totalExpenses =
              double.tryParse(data['egresos']?.toString() ?? '0') ?? 0.0;
          movements = List<Map<String, dynamic>>.from(
            data['movimientos'] ?? [],
          );
          isLoading = false;
        });
      } else {
        _loadStaticData();
      }
    } catch (e) {
      _loadStaticData();
    }
  }

  // --- GENERACIÓN DE PDF (ESTILO CONTADOR) ---

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "PLATTO - REPORTE DE CAJA",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "Fecha: ${DateTime.now().toString().split('.')[0]}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Resumen financiero estilizado
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text(
                      "Ingresos: \$${totalIncome.toStringAsFixed(2)}",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.Text(
                      "Egresos: \$${totalExpenses.toStringAsFixed(2)}",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
                      ),
                    ),
                    pw.Text(
                      "Balance: \$${netBalance.toStringAsFixed(2)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Tabla detallada
              pw.Text(
                "Detalle de Transacciones",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          "Descripción",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("Tipo"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("Método"),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("Monto"),
                      ),
                    ],
                  ),
                  ...movements.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item['description']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            item['type'] == 'income' ? 'Ingreso' : 'Egreso',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item['payment_method']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            "\$${item['amount'].toStringAsFixed(2)}",
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final String path =
          "${directory.path}/Reporte_Platto_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF guardado correctamente")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // --- INTERFAZ UI ---

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final item = movements[index];
                      bool isIncome = item['type'] == 'income';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            "${item['time']} • ${item['payment_method']}",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
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
                        "GUARDAR Y ABRIR PDF",
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
