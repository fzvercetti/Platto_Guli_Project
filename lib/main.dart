import 'package:flutter/material.dart';
import '../screens/menu_page.dart'; // Importas tu nueva pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Platto Menú',
      theme: ThemeData(
        fontFamily: 'Roboto', // Fuente limpia por defecto en Android
      ),
      home: const PlattoMenuPage(), // Llama a la pantalla que separaste
    );
  }
}
