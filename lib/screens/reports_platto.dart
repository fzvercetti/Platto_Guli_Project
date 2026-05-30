import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsPlatto extends StatefulWidget {
  const ReportsPlatto({super.key});

  @override
  State<ReportsPlatto> createState() => _ReportsPlattoState();
}

class _ReportsPlattoState extends State<ReportsPlatto> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    // Reemplaza con tu URL real cuando el backend esté listo
    // final response = await http.get(Uri.parse("http://127.0.0.1:5000/api/reportes/general"));

    // Simulación de respuesta
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      data = {
        "sales": {"total": 12400, "orders": 45},
        "inventory": {"low_stock": 5, "total_items": 120},
        "cash": {"income": 15000, "expenses": 3000, "balance": 12000},
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFDE7E51);
    const Color darkBg = Color(0xFF0E1E40);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Reportes",
          style: TextStyle(color: darkBg, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandOrange),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: brandOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Sales", Icons.trending_up, brandOrange),
                  _buildSummaryCard(
                    "Total Sales",
                    "\$${data['sales']['total']}",
                    "Orders: ${data['sales']['orders']}",
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Inventory", Icons.inventory, darkBg),
                  _buildSummaryCard(
                    "Low Stock",
                    "${data['inventory']['low_stock']} items",
                    "Total items: ${data['inventory']['total_items']}",
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle(
                    "Cash / Payments",
                    Icons.account_balance_wallet,
                    darkBg,
                  ),
                  _buildSummaryCard(
                    "Final Balance",
                    "\$${data['cash']['balance']}",
                    "Income: \$${data['cash']['income']} | Expenses: \$${data['cash']['expenses']}",
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String mainValue, String subValue) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            mainValue,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            subValue,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
