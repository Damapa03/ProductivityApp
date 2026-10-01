import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/models/daily_schedule.dart';
import 'package:productyivity_app/models/schedule_event.dart';

void main() {
  test('eventsOn filtra por el día de inicio', () {
    final schedule = DailySchedule.empty('ana@flowly.com').copyWith(
      events: [
        ScheduleEvent(
          id: 'e1',
          title: 'Hoy',
          start: DateTime(2026, 9, 28, 10),
          end: DateTime(2026, 9, 28, 11),
        ),
        ScheduleEvent(
          id: 'e2',
          title: 'Mañana',
          start: DateTime(2026, 9, 29, 10),
          end: DateTime(2026, 9, 29, 11),
        ),
      ],
    );

    final today = schedule.eventsOn(DateTime(2026, 9, 28));
    expect(today.map((e) => e.title).toList(), ['Hoy']);
  });

  group('eventsBetween filtra por rango de la semana', () {
    final schedule = DailySchedule.empty('ana@flowly.com').copyWith(
      events: [
        ScheduleEvent(
          id: 'lunes',
          title: 'Lunes',
          start: DateTime(2026, 9, 28, 0),
          end: DateTime(2026, 9, 28, 1),
        ),
        ScheduleEvent(
          id: 'domingo',
          title: 'Domingo',
          start: DateTime(2026, 10, 4, 23, 45),
          end: DateTime(2026, 10, 5),
        ),
        ScheduleEvent(
          id: 'siguiente',
          title: 'Lunes siguiente',
          start: DateTime(2026, 10, 5, 0),
          end: DateTime(2026, 10, 5, 1),
        ),
        ScheduleEvent(
          id: 'anterior',
          title: 'Semana anterior',
          start: DateTime(2026, 9, 27, 12),
          end: DateTime(2026, 9, 27, 13),
        ),
      ],
    );

    // Semana del lunes 28 al domingo 4, cruzando el cambio de mes.
    final from = DateTime(2026, 9, 28);
    final to = DateTime(2026, 10, 5);

    test('incluye desde el inicio y excluye el límite superior', () {
      expect(
        schedule.eventsBetween(from, to).map((e) => e.title).toList(),
        ['Lunes', 'Domingo'],
      );
    });

    test('no incluye lo que empieza justo al terminar la semana', () {
      final titles = schedule.eventsBetween(from, to).map((e) => e.title);
      expect(titles, isNot(contains('Lunes siguiente')));
    });

    test('excluye la semana anterior', () {
      final titles = schedule.eventsBetween(from, to).map((e) => e.title);
      expect(titles, isNot(contains('Semana anterior')));
    });

    test('funciona también dentro de un mismo mes', () {
      final dentroDeSeptiembre = schedule.eventsBetween(
        DateTime(2026, 9, 28),
        DateTime(2026, 9, 29),
      );
      expect(dentroDeSeptiembre.map((e) => e.title).toList(), ['Lunes']);
    });
  });

  group('eventsBetween cruza el cambio de año', () {
    // Semana del lunes 28 de diciembre de 2026 al domingo 3 de enero de 2027.
    final schedule = DailySchedule.empty('ana@flowly.com').copyWith(
      events: [
        ScheduleEvent(
          id: 'lunes',
          title: 'Lunes 28',
          start: DateTime(2026, 12, 28, 23, 30),
          end: DateTime(2026, 12, 29),
        ),
        ScheduleEvent(
          id: 'jueves',
          title: 'Jueves 31',
          start: DateTime(2026, 12, 31, 22),
          end: DateTime(2027, 1, 1, 1),
        ),
        ScheduleEvent(
          id: 'domingo',
          title: 'Domingo 3',
          start: DateTime(2027, 1, 3),
          end: DateTime(2027, 1, 3, 1),
        ),
        ScheduleEvent(
          id: 'fuera',
          title: 'Lunes 4',
          start: DateTime(2027, 1, 4),
          end: DateTime(2027, 1, 4, 1),
        ),
      ],
    );
    final from = DateTime(2026, 12, 28);
    final to = DateTime(2027, 1, 4);

    test('incluye las franjas de los dos años de la semana', () {
      expect(
        schedule.eventsBetween(from, to).map((e) => e.title).toList(),
        ['Lunes 28', 'Jueves 31', 'Domingo 3'],
      );
    });

    test('la franja de madrugada del 31 sigue siendo del año viejo', () {
      // Empieza el 31 a las 22:00 y termina ya en 2027: se filtra por el
      // inicio, así que pertenece a la semana en la que empezó.
      final event = schedule.eventsBetween(from, to).firstWhere(
        (e) => e.id == 'jueves',
      );
      expect(event.start.year, 2026);
      expect(event.end.year, 2027);
    });

    test('el lunes siguiente al cambio de año queda fuera', () {
      final titles = schedule.eventsBetween(from, to).map((e) => e.title);
      expect(titles, isNot(contains('Lunes 4')));
    });
  });

  test('duration calcula el intervalo de la franja', () {
    final event = ScheduleEvent(
      id: 'e1',
      title: 'Deep work',
      start: DateTime(2026, 9, 28, 10),
      end: DateTime(2026, 9, 28, 12),
    );

    expect(event.duration, const Duration(hours: 2));
  });

  test('el contrato JSON es estable (toJson/fromJson)', () {
    final schedule = DailySchedule.empty('ana@flowly.com').copyWith(
      events: [
        ScheduleEvent(
          id: 'e1',
          title: 'Standup',
          start: DateTime(2026, 9, 28, 9),
          end: DateTime(2026, 9, 28, 9, 30),
        ),
      ],
    );

    final restored = DailySchedule.fromJson(
      Map<String, Object?>.from(schedule.toJson()),
    );

    expect(restored.ownerId, 'ana@flowly.com');
    expect(restored.events, hasLength(1));
    expect(restored.events.single.title, 'Standup');
    expect(restored.events.single.start, DateTime(2026, 9, 28, 9));
    expect(restored.events.single.end, DateTime(2026, 9, 28, 9, 30));
  });
}