import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/data/schedule_repository.dart';
import 'package:productyivity_app/models/daily_schedule.dart';
import 'package:productyivity_app/models/schedule_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalScheduleRepository', () {
    test('load devuelve null si aún no hay horario para ese usuario', () async {
      final repo = LocalScheduleRepository();

      expect(await repo.load('usuario@flowly.com'), isNull);
    });

    test('los horarios quedan aislados por email de usuario', () async {
      final repo = LocalScheduleRepository();
      final ana = DailySchedule.empty('ana@flowly.com').copyWith(
        events: [
          ScheduleEvent(
            id: 'e1',
            title: 'Deep work',
            start: DateTime(2026, 9, 28, 10),
            end: DateTime(2026, 9, 28, 12),
          ),
        ],
      );
      final bob = DailySchedule.empty('bob@flowly.com');

      await repo.save('ana@flowly.com', ana);
      await repo.save('bob@flowly.com', bob);

      final restoredA = await repo.load('ana@flowly.com');
      final restoredB = await repo.load('bob@flowly.com');

      expect(restoredA, isNotNull);
      expect(restoredA!.ownerId, 'ana@flowly.com');
      expect(restoredA.events.single.title, 'Deep work');
      expect(restoredB, isNotNull);
      // Las franjas de Ana no deben contaminar el horario de Bob.
      expect(restoredB!.events, isEmpty);
    });

    test('guarda y recupera un horario con franjas', () async {
      final repo = LocalScheduleRepository();
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

      await repo.save('ana@flowly.com', schedule);
      final restored = await repo.load('ana@flowly.com');

      expect(restored, isNotNull);
      expect(restored!.events.single.title, 'Standup');
      expect(restored.events.single.start, DateTime(2026, 9, 28, 9));
      expect(restored.events.single.end, DateTime(2026, 9, 28, 9, 30));
    });
  });
}