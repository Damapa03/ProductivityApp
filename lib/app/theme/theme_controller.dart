import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencia de tema de la app.
///
/// Es un [ValueNotifier] con una única instancia compartida ([instance]) para
/// que [FlowlyApp] la escuche y cualquier pantalla pueda cambiarla (hoy el
/// interruptor de «Modo oscuro» del perfil). Se persiste en
/// `shared_preferences` con la misma convención que el resto de datos locales.
///
/// El interruptor del mockup solo distingue claro y oscuro, así que no se usa
/// `ThemeMode.system`: apagado es claro y encendido es oscuro.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.light);

  /// Instancia compartida por toda la app.
  static final ThemeController instance = ThemeController._();

  /// Clave de `shared_preferences` de la preferencia de tema.
  static const String storageKey = 'flowly.theme.v1';

  static const String _darkValue = 'dark';
  static const String _lightValue = 'light';

  /// Si el tema activo es el oscuro.
  bool get isDark => value == ThemeMode.dark;

  /// Lee la preferencia guardada; si no hay ninguna, deja el tema claro.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(storageKey) == _darkValue
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  /// Activa o desactiva el modo oscuro y guarda la elección.
  Future<void> setDark(bool dark) async {
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    if (value == mode) return;
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, dark ? _darkValue : _lightValue);
  }
}
