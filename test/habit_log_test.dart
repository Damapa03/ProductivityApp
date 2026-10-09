import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/models/habit.dart';

/// Día a las 00:00, como los que usa la pantalla.
DateTime _day(int year, int month, int day) => DateTime(year, month, day);

/// Hábito creado el [createdAt] indicado.
Habit _habit(String id, {DateTime? createdAt, String title = 'Beber 2 L'}) {
  return Habit(
    id: id,
    title: title,
    createdAt: createdAt ?? _day(2026, 10, 1),
  );
}

/// Registro con dos hábitos (agua y lectura) y ningún check.
HabitLog _log() => HabitLog(
      ownerId: 'ana@flowly.com',
      habits: [
        _habit('agua', title: 'Beber 2 L de agua'),
        _habit('lectura', title: '30 min de lectura'),
      ],
      completions: const {},
    );

void main() {
  group('DayStatus', () {
    final today = _day(2026, 10, 3);

    test('un día anterior con todos los hábitos cumplidos queda en verde', () {
      final completo = _log().toggle('agua', _day(2026, 10, 2)).toggle(
            'lectura',
            _day(2026, 10, 2),
          );

      expect(completo.statusOf(_day(2026, 10, 2), today), DayStatus.done);
    });

    test('un día anterior con algún hábito sin cumplir queda en rojo', () {
      final aMedias = _log().toggle('agua', _day(2026, 10, 2));

      expect(aMedias.statusOf(_day(2026, 10, 2), today), DayStatus.missed);
    });

    test('el día de hoy con algo pendiente se queda en neutro', () {
      expect(_log().statusOf(today, today), DayStatus.neutral);
    });

    test('el día de hoy pasa a verde en cuanto se cumplen todos', () {
      final completo = _log().toggle('agua', today).toggle('lectura', today);

      expect(completo.statusOf(today, today), DayStatus.done);
    });

    test('un día por venir queda apagado tenga lo que tenga marcado', () {
      final futuro = _log().toggle('agua', _day(2026, 10, 5));

      expect(futuro.statusOf(_day(2026, 10, 5), today), DayStatus.future);
    });

    test('un día anterior a los hábitos es neutro, no rojo', () {
      final conHobbies = HabitLog(
        ownerId: 'ana@flowly.com',
        habits: [_habit('agua', createdAt: today)],
        completions: const {},
      );

      expect(conHobbies.statusOf(_day(2026, 10, 1), today), DayStatus.neutral);
    });

    test('sin hábitos no hay nada que juzgar', () {
      expect(
        HabitLog.empty('ana@flowly.com').statusOf(today, today),
        DayStatus.neutral,
      );
    });

    test('la hora del día no altera el estado', () {
      // Un check marcado a las 23:59 sigue siendo del día 2, no del 3.
      final conHora = _log().toggle('agua', DateTime(2026, 10, 2, 23, 59));

      expect(conHora.statusOf(_day(2026, 10, 2), today), DayStatus.missed);
    });
  });

  group('checks', () {
    test('un check solo afecta al día marcado', () {
      final marcado = _log().toggle('agua', _day(2026, 10, 2));

      expect(marcado.isDone('agua', _day(2026, 10, 2)), isTrue);
      expect(marcado.isDone('agua', _day(2026, 10, 3)), isFalse);
      expect(marcado.isDone('lectura', _day(2026, 10, 2)), isFalse);
      // El registro original no se toca.
      expect(_log().isDone('agua', _day(2026, 10, 2)), isFalse);
    });

    test('volver a marcar desmarca', () {
      final marcado = _log().toggle('agua', _day(2026, 10, 2));

      expect(
        marcado.toggle('agua', _day(2026, 10, 2)).isDone('agua', _day(2026, 10, 2)),
        isFalse,
      );
    });

    test('el progreso cuenta solo los hábitos vigentes ese día', () {
      final conNuevo = _log().addHabit(
        _habit('nuevo', createdAt: _day(2026, 10, 3), title: 'Estiramientos'),
      );

      // El día 2 solo había dos hábitos: el nuevo no cuenta como incumplido.
      final delDia2 = conNuevo.toggle('agua', _day(2026, 10, 2));
      expect(delDia2.progressOn(_day(2026, 10, 2)), (total: 2, done: 1));
      expect(delDia2.hasPendingOn(_day(2026, 10, 2)), isTrue);
      // Y el 3 ya son tres.
      expect(conNuevo.progressOn(_day(2026, 10, 3)), (total: 3, done: 0));
    });

    test('un hábito creado a media tarde cuenta para ese mismo día', () {
      final conNuevo = _log().addHabit(
        _habit('tarde', createdAt: DateTime(2026, 10, 3, 22, 30)),
      );

      expect(conNuevo.progressOn(_day(2026, 10, 3)).total, 3);
    });

    test('borrar un hábito se lleva sus checks', () {
      final conChecks = _log()
          .toggle('agua', _day(2026, 10, 2))
          .toggle('lectura', _day(2026, 10, 3));

      final sinAgua = conChecks.removeHabit('agua');

      expect(sinAgua.habits.map((h) => h.id), ['lectura']);
      expect(sinAgua.completions, {'lectura@2026-10-03'});
      expect(sinAgua.isDone('agua', _day(2026, 10, 2)), isFalse);
    });

    test('un hábito repetido no se añade dos veces', () {
      expect(_log().addHabit(_habit('agua')).habits, hasLength(2));
    });
  });

  group('JSON', () {
    test('el registro sobrevive a un viaje de ida y vuelta', () {
      final log = HabitLog(
        ownerId: 'ana@flowly.com',
        habits: [_habit('agua')],
        completions: const {'agua@2026-10-02'},
      );

      final restaurado = HabitLog.fromJson(log.toJson());

      expect(restaurado.ownerId, 'ana@flowly.com');
      expect(restaurado.habits.single.id, 'agua');
      expect(restaurado.habits.single.title, 'Beber 2 L');
      expect(restaurado.isDone('agua', _day(2026, 10, 2)), isTrue);
    });

    test('un JSON sin datos devuelve un registro vacío', () {
      final vacio = HabitLog.fromJson(const <String, Object?>{});

      expect(vacio.ownerId, '');
      expect(vacio.habits, isEmpty);
      expect(vacio.completions, isEmpty);
    });
  });
}