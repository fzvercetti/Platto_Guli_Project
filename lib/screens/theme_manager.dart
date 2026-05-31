import 'package:flutter/material.dart';

// Este notificador es global y permite cambiar el tema desde cualquier pantalla
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
