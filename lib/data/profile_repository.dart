import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

/// Repositorio de perfil. Interfaz desacoplada de la implementación
/// para poder migrar a una API externa sin tocar la UI.
abstract interface class ProfileRepository {
  Future<Profile?> load();
  Future<void> save(Profile profile);
  Future<void> clear();
}

/// Implementación local con `shared_preferences` (fase sin API).
class LocalProfileRepository implements ProfileRepository {
  static const String _key = 'flowly.profile.v1';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<Profile?> load() async {
    final raw = (await _prefs).getString(_key);
    if (raw == null) return null;
    try {
      return Profile.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } catch (_) {
      return null; // dato corrupto → sin perfil
    }
  }

  @override
  Future<void> save(Profile profile) async {
    await (await _prefs).setString(_key, jsonEncode(profile.toJson()));
  }

  @override
  Future<void> clear() async {
    await (await _prefs).remove(_key);
  }
}
