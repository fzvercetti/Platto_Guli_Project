import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConciliationPlatto extends StatefulWidget {
  const ConciliationPlatto({super.key});

  @override
  State<ConciliationPlatto> createState() => _ConciliationPlattoState();
}

class _ConciliationPlattoState extends State<ConciliationPlatto> {
  final String baseUrl = "http://127.0.0.1:5000";

  bool isLoading = true;
  double initialBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double expectedBalance = 0.0;
  double currentDifference = 0.0; // Nueva variable para calcular la diferencia

  final TextEditingController cashController = TextEditingController();
  final TextEditingController cardsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSystemSummary();

    // Escuchar cambios en los campos de texto para calcular en tiempo real
    cashController.addListener(_calculateDifference);
    cardsController.addListener(_calculateDifference);
  }

  @override
  void dispose() {
    cashController.dispose();
    cardsController.dispose();
    super.dispose();
  }

  // --- CÁLCULO EN TIEMPO REAL ---
  void _calculateDifference() {
    double physicalCash = double.tryParse(cashController.text) ?? 0.0;
    double physicalCards = double.tryParse(cardsController.text) ?? 0.0;

    setState(() {
      currentDifference = (physicalCash + physicalCards) - expectedBalance;
    });
  }

  // --- CONNECT TO DATABASE (FETCH SUMMARY) ---
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
        _calculateDifference(); // Calcular inicial
      }
    } catch (e) {
      print("Error fetching summary: $e");
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

  // --- SAVE CONCILIATION TO DATABASE (POST) ---
  Future<void> _saveConciliation() async {
    if (cashController.text.isEmpty || cardsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter physical amounts")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cash/conciliation'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "physical_cash": double.parse(cashController.text),
          "physical_cards": double.parse(cardsController.text),
          "expected_balance": expectedBalance,
          "difference":
              currentDifference, // Enviamos también la diferencia a la BD
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Shift closed successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving conciliation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Color(0xFF4A5568);
    const Color bgGrey = Color(0xFFF7F9FA);
    const Color textDark = Color(0xFF2D3748);
    const Color textGrey = Color(0xFF718096);
    const Color brandOrange = Color(0xFFDE7E51); // Naranja del botón

    // Lógica para colores de la diferencia
    Color diffColor = currentDifference == 0
        ? Colors.green
        : const Color(0xFFE53E3E); // Rojo si hay diferencia

    Color diffBgColor = currentDifference == 0
        ? Colors.green.shade50
        : const Color(0xFFFFF5F5); // Rojo clarito de fondo

    String diffText = "Exact match";
    if (currentDifference > 0) diffText = "Diferencia detectada: Sobrante";
    if (currentDifference < 0) diffText = "Diferencia detectada: Faltante";

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          "Detalle de Corte Automatizado",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- CARD 1: SYSTEM SUMMARY ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Resumen de Sistema",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSummaryRow(
                          "Balance Inicial:",
                          "\$${initialBalance.toStringAsFixed(2)}",
                          labelColor: textGrey,
                          valueColor: textGrey,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          "Total de Ingresos:",
                          "+\$${totalIncome.toStringAsFixed(2)}",
                          labelColor: textGrey,
                          valueColor: const Color(0xFF38A169),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          "Total de Gastos:",
                          "-\$${totalExpenses.toStringAsFixed(2)}",
                          labelColor: textGrey,
                          valueColor: const Color(0xFFE53E3E),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(thickness: 1),
                        ),
                        _buildSummaryRow(
                          "Balance Esperado:",
                          "\$${expectedBalance.toStringAsFixed(2)}",
                          labelColor: textDark,
                          valueColor: textDark,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ingreso Físico",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Ingresos en efectivo",
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(cashController, "e.g. 3750.00"),

                        const SizedBox(height: 20),

                        const Text(
                          "Ingresos con tarjeta",
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(cardsController, "e.g. 50.00"),

                        const SizedBox(height: 24),

                        // --- SECCIÓN DE DIFERENCIA (NUEVO) ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: diffBgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: diffColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Diferencia",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
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
                                      diffText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- BOTÓN CERRAR TURNO (NUEVO) ---
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _saveConciliation,
                            child: const Text(
                              "CERRAR TURNO Y GUARDAR",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    required Color labelColor,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: labelColor,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF4F5F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        suffixIcon: const Icon(
          Icons.edit_outlined,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}
