import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_config.dart';

import 'package:platto_app/utils/api_config.dart';

class ConciliationPlatto extends StatefulWidget {
  const ConciliationPlatto({super.key});

  @override
  State<ConciliationPlatto> createState() => _ConciliationPlattoState();
}

class _ConciliationPlattoState extends State<ConciliationPlatto> {
  final String baseUrl = ApiConfig.baseUrl;

  bool isLoading = true;
  double initialBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double expectedBalance = 0.0;
  double currentDifference = 0.0;

  final TextEditingController cashController = TextEditingController();
  final TextEditingController cardsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSystemSummary();
    cashController.addListener(_calculateDifference);
    cardsController.addListener(_calculateDifference);
  }

  @override
  void dispose() {
    cashController.dispose();
    cardsController.dispose();
    super.dispose();
  }

  void _calculateDifference() {
    double physicalCash = double.tryParse(cashController.text) ?? 0.0;
    double physicalCards = double.tryParse(cardsController.text) ?? 0.0;
    setState(() {
      currentDifference = (physicalCash + physicalCards) - expectedBalance;
    });
  }

  Future<void> _fetchSystemSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cash/summary_today'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          initialBalance = (data['initial_balance'] ?? 0).toDouble();
          totalIncome = (data['income'] ?? 0).toDouble();
          totalExpenses = (data['expenses'] ?? 0).toDouble();
          expectedBalance = initialBalance + totalIncome - totalExpenses;
          isLoading = false;
        });
        _calculateDifference();
      }
    } catch (e) {
      setState(() {
        initialBalance = 500.00;
        totalIncome = 3500.00;
        totalExpenses = 200.00;
        expectedBalance = 3800.00;
        isLoading = false;
      });
      _calculateDifference();
    }
  }

  Future<void> _saveConciliation() async {
    // 1. Preparamos el objeto con los datos
    final body = {
      "expected_balance": expectedBalance,
      "physical_cash": double.tryParse(cashController.text) ?? 0.0,
      "physical_cards": double.tryParse(cardsController.text) ?? 0.0,
      "difference": currentDifference,
    };

    try {
      print("Enviando a: $baseUrl/api/cash/guardar_cierre");
      print("Cuerpo: $body");

      // 2. Hacemos la petición POST
      final response = await http.post(
        Uri.parse('$baseUrl/api/cash/guardar_cierre'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      // 3. Verificamos la respuesta
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cierre guardado exitosamente"), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error del servidor: ${response.body}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo conectar al servidor: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detectamos modo oscuro
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. Colores semánticos adaptados (más suaves para dark mode)
    final Color diffColor = currentDifference == 0
        ? Colors.green
        : Colors.redAccent;
    final Color diffBgColor = currentDifference == 0
        ? (isDarkMode
              ? Colors.green.shade900.withValues(alpha: 0.2)
              : Colors.green.shade50)
        : (isDarkMode
              ? Colors.red.shade900.withValues(alpha: 0.2)
              : const Color(0xFFFFF5F5));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5568),
        title: const Text(
          "Detalle de Corte Automatizado",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- CARD 1: SUMMARY ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Resumen de Sistema",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSummaryRow(
                          "Balance Inicial:",
                          "\$${initialBalance.toStringAsFixed(2)}",
                          isBold: false,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          "Total de Ingresos:",
                          "+\$${totalIncome.toStringAsFixed(2)}",
                          valueColor: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          "Total de Gastos:",
                          "-\$${totalExpenses.toStringAsFixed(2)}",
                          valueColor: Colors.redAccent,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(),
                        ),
                        _buildSummaryRow(
                          "Balance Esperado:",
                          "\$${expectedBalance.toStringAsFixed(2)}",
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CARD 2: PHYSICAL RECORD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ingreso Físico",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLabel("Ingresos en efectivo"),
                        _buildInputField(
                          cashController,
                          "e.g. 3750.00",
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Ingresos con tarjeta"),
                        _buildInputField(
                          cardsController,
                          "e.g. 50.00",
                          isDarkMode,
                        ),
                        const SizedBox(height: 24),

                        // --- DIFERENCIA ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: diffBgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: diffColor.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Diferencia",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "\$ ${currentDifference.abs().toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: diffColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      currentDifference == 0
                                          ? Icons.check_circle_outline
                                          : Icons.warning_amber_rounded,
                                      color: diffColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      currentDifference == 0
                                          ? "Exact match"
                                          : (currentDifference > 0
                                                ? "Sobrante"
                                                : "Faltante"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDE7E51),
                            ),
                            onPressed: _saveConciliation,
                            child: const Text(
                              "CERRAR TURNO Y GUARDAR",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w500));

  Widget _buildSummaryRow(
    String title,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    bool isDarkMode,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey[800]
            : Colors.grey[100], // Fondo dinámico
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
