import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DailySalesPage extends StatefulWidget {
  const DailySalesPage({super.key});
  @override
  State<DailySalesPage> createState() => _DailySalesPageState();
}

class _DailySalesPageState extends State<DailySalesPage> {
  List<dynamic> _sales = [
    {"id": 1, "total": 250.0, "metodo": "Efectivo"},
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/ventas_dia"),
      );
      if (response.statusCode == 200) {
        setState(() => _sales = jsonDecode(response.body));
      }
    } catch (e) {
      // Se queda con los datos estáticos (_sales inicial)
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ventas del Día")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _sales.length,
              itemBuilder: (context, i) => ListTile(
                title: Text("Venta #${_sales[i]['id']}"),
                trailing: Text("\$${_sales[i]['total']}"),
              ),
            ),
    );
  }
}
