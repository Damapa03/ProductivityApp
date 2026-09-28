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