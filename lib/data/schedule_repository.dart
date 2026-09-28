import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_schedule.dart';

/// Repositorio del horario de agenda diaria.
///
/// Los datos quedan asociados al usuario por `ownerId` (email del perfil).
/// Interfaz desacoplada de la implementación para poder migrar a una API
/// externa sin tocar la UI (ver `AGENTS.md`).
abstract interface class ScheduleRepository {
  Future<DailySchedule?> load(String ownerId);
  Future<void> save(String ownerId, DailySchedule schedule);
}

/// Implementación local con `shared_preferences` (fase sin API).
class LocalScheduleRepository implements ScheduleRepository {
  static const String _keyPrefix = 'flowly.schedule.v1.';

  static String _keyFor(String ownerId) => '$_keyPrefix$ownerId';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<DailySchedule?> load(String ownerId) async {
    final raw = (await _prefs).getString(_keyFor(ownerId));
    if (raw == null) return null;
    try {
      return DailySchedule.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } catch (_) {
      return null; // dato corrupto → sin horario
    }
  }

  @override
  Future<void> save(String ownerId, DailySchedule schedule) async {
    await (await _prefs).setString(_keyFor(ownerId), jsonEncode(schedule.toJson()));
  }
}