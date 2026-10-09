import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/kanban_board.dart';

/// Repositorio del tablero kanban diario.
///
/// Los datos quedan asociados al usuario por `ownerId` (email del perfil),
/// de modo que cada usuario tiene su propio tablero. Interfaz desacoplada de
/// la implementación para poder migrar a una API externa sin tocar la UI.
abstract interface class KanbanRepository {
  Future<KanbanBoard?> load(String ownerId);
  Future<void> save(String ownerId, KanbanBoard board);
}

/// Implementación local con `shared_preferences` (fase sin API).
class LocalKanbanRepository implements KanbanRepository {
  static const String _keyPrefix = 'flowly.kanban.v1.';

  static String _keyFor(String ownerId) => '$_keyPrefix$ownerId';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<KanbanBoard?> load(String ownerId) async {
    final raw = (await _prefs).getString(_keyFor(ownerId));
    if (raw == null) return null;
    try {
      return KanbanBoard.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } catch (_) {
      return null; // dato corrupto → sin tablero
    }
  }

  @override
  Future<void> save(String ownerId, KanbanBoard board) async {
    await (await _prefs).setString(_keyFor(ownerId), jsonEncode(board.toJson()));
  }
}