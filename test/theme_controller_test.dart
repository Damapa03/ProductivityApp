import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/app/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeController.instance.value = ThemeMode.light;
  });

  test('arranca en claro', () {
    expect(ThemeController.instance.value, ThemeMode.light);
    expect(ThemeController.instance.isDark, isFalse);
  });

  test('setDark cambia el modo y lo persiste', () async {
    await ThemeController.instance.setDark(true);
    expect(ThemeController.instance.value, ThemeMode.dark);
    expect(ThemeController.instance.isDark, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ThemeController.storageKey), 'dark');
  });

  test('volver a claro también se persiste', () async {
    await ThemeController.instance.setDark(true);
    await ThemeController.instance.setDark(false);

    expect(ThemeController.instance.value, ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ThemeController.storageKey), 'light');
  });

  test('load recupera la preferencia oscura guardada', () async {
    SharedPreferences.setMockInitialValues({
      ThemeController.storageKey: 'dark',
    });

    await ThemeController.instance.load();

    expect(ThemeController.instance.value, ThemeMode.dark);
  });

  test('load sin preferencia deja el tema claro', () async {
    await ThemeController.instance.load();

    expect(ThemeController.instance.value, ThemeMode.light);
  });
}
