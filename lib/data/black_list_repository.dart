import 'package:shared_preferences/shared_preferences.dart';

/// Repositorio de la lista negra (apuntes a modo de recordatorio).
///
/// A diferencia de tareas, agenda y perfil, la persistencia de la lista negra
/// es **intencionalmente solo local**: se guarda texto plano en el dispositivo
/// y NO debe migrarse a una API o base de datos externa. El contrato no es un
/// JSON estable, sino la propia cadena de texto que se escribe.
abstract interface class BlackListRepository {
  /// Texto guardado del usuario, o `null` si aún no ha escrito nada.
  Future<String?> load(String ownerId);

  /// Guarda el texto completo del usuario (se sobrescribe con cada cambio).
  Future<void> save(String ownerId, String text);
}

/// Implementación local con `shared_preferences` (fase sin API).
class LocalBlackListRepository implements BlackListRepository {
  static const String _keyPrefix = 'flowly.blacklist.v1.';

  static String _keyFor(String ownerId) => '$_keyPrefix$ownerId';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> load(String ownerId) async {
    return (await _prefs).getString(_keyFor(ownerId));
  }

  @override
  Future<void> save(String ownerId, String text) async {
    await (await _prefs).setString(_keyFor(ownerId), text);
  }
}