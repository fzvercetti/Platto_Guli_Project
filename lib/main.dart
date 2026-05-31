import 'package:flutter/material.dart';
import '../screens/menu_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Platto Menú',

          theme: ThemeData.light(), // Tema claro
          darkTheme: ThemeData.dark(), // Tema oscuro
          themeMode: currentMode, // El tema que se aplica actualmente

          home: const PlattoMenuPage(),
        );
      },
    );
  }
}
