import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/data/habit_repository.dart';
import 'package:productyivity_app/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registro de ejemplo: un hábito ya marcado hoy.
HabitLog _log(String ownerId) {
  final today = DateTime.now();
  return HabitLog(
    ownerId: ownerId,
    habits: [
      Habit(id: 'agua', title: 'Beber 2 L de agua', createdAt: today),
    ],
    completions: {
      'agua@${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}',
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalHabitRepository', () {
    test('load devuelve null si aún no hay registro para ese usuario',
        () async {
      final repo = LocalHabitRepository();

      expect(await repo.load('usuario@flowly.com'), isNull);
    });

    test('el registro sobrevive a un guardado y una carga', () async {
      final repo = LocalHabitRepository();
      final log = _log('ana@flowly.com');

      await repo.save('ana@flowly.com', log);
      final restaurado = await repo.load('ana@flowly.com');

      expect(restaurado, isNotNull);
      expect(restaurado!.ownerId, 'ana@flowly.com');
      expect(restaurado.habits.single.title, 'Beber 2 L de agua');
      expect(restaurado.completions, log.completions);
    });

    test('los registros quedan aislados por email de usuario', () async {
      final repo = LocalHabitRepository();
      await repo.save('ana@flowly.com', _log('ana@flowly.com'));

      // Bob no tiene registro propio, no el de Ana.
      expect(await repo.load('bob@flowly.com'), isNull);
    });

    test('un dato corrupto se descarta en lugar de romper la carga', () async {
      SharedPreferences.setMockInitialValues(
        {'flowly.habits.v1.ana@flowly.com': 'no es json'},
      );

      expect(await LocalHabitRepository().load('ana@flowly.com'), isNull);
    });
  });
}