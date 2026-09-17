import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/data/kanban_repository.dart';
import 'package:productyivity_app/models/kanban_board.dart';
import 'package:productyivity_app/models/kanban_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalKanbanRepository', () {
    test('load devuelve null si aún no hay tablero para ese usuario', () async {
      final repo = LocalKanbanRepository();

      expect(await repo.load('usuario@flowly.com'), isNull);
    });

    test('los tableros quedan aislados por email de usuario', () async {
      final repo = LocalKanbanRepository();
      final ana = KanbanBoard.withDefaultColumns('ana@flowly.com');
      final bob = KanbanBoard.withDefaultColumns('bob@flowly.com');

      await repo.save('ana@flowly.com', ana);
      await repo.save('bob@flowly.com', bob);

      final restoredA = await repo.load('ana@flowly.com');
      final restoredB = await repo.load('bob@flowly.com');

      expect(restoredA, isNotNull);
      expect(restoredA!.ownerId, 'ana@flowly.com');
      expect(restoredA.columns.map((c) => c.name).toList(),
          ['Search', 'TODO', 'Doing', 'Done']);
      expect(restoredB, isNotNull);
      expect(restoredB!.ownerId, 'bob@flowly.com');
      // La tarea de Ana no debe contaminar el tablero de Bob.
      expect(restoredB.tasks, isEmpty);
    });

    test('guarda y recupera un tablero con tareas', () async {
      final repo = LocalKanbanRepository();
      final board = KanbanBoard.withDefaultColumns('ana@flowly.com');
      final withTask = board.copyWith(
        tasks: [
          KanbanTask(
            id: 't1',
            title: 'Hacer café',
            columnId: board.columns.first.id,
            createdAt: DateTime(2026, 9, 17),
          ),
        ],
      );

      await repo.save('ana@flowly.com', withTask);
      final restored = await repo.load('ana@flowly.com');

      expect(restored!.tasks.single.title, 'Hacer café');
      expect(restored.tasksFor(board.columns.first.id).single.title,
          'Hacer café');
    });
  });
}