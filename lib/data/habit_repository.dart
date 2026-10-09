import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

/// Repositorio del registro de hábitos.
///
/// Los datos quedan asociados al usuario por `ownerId` (email del perfil), de
/// modo que cada usuario tiene sus hábitos y sus checks. Interfaz desacoplada
/// de la implementación para poder migrar a una API externa sin tocar la UI.
abstract interface class HabitRepository {
  Future<HabitLog?> load(String ownerId);
  Future<void> save(String ownerId, HabitLog log);
}

/// Implementación local con `shared_preferences` (fase sin API).
class LocalHabitRepository implements HabitRepository {
  static const String _keyPrefix = 'flowly.habits.v1.';

  static String _keyFor(String ownerId) => '$_keyPrefix$ownerId';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<HabitLog?> load(String ownerId) async {
    final raw = (await _prefs).getString(_keyFor(ownerId));
    if (raw == null) return null;
    try {
      return HabitLog.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } catch (_) {
      return null; // dato corrupto → sin registro
    }
  }

  @override
  Future<void> save(String ownerId, HabitLog log) async {
    await (await _prefs).setString(_keyFor(ownerId), jsonEncode(log.toJson()));
  }
}