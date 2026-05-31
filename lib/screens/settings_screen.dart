import 'package:flutter/material.dart';
import '../main.dart'; // Importamos el themeNotifier desde main.dart

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        backgroundColor: const Color(0xFF4A5568),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, ThemeMode currentMode, __) {
              return SwitchListTile(
                title: const Text("Modo Oscuro"),
                subtitle: Text(
                  currentMode == ThemeMode.dark ? "Activado" : "Desactivado",
                ),
                value: currentMode == ThemeMode.dark,
                activeColor: const Color(0xFFDE7E51), // Tu naranja corporativo
                onChanged: (bool value) {
                  themeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              );
            },
          ),
          const Divider(),
          // Aquí puedes agregar más opciones de configuración después
        ],
      ),
    );
  }
}
