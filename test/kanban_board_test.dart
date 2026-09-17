import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/models/kanban_board.dart';
import 'package:productyivity_app/models/kanban_task.dart';

void main() {
  group('KanbanBoard', () {
    test('withDefaultColumns crea 4 columnas en orden Search/TODO/Doing/Done', () {
      final board = KanbanBoard.withDefaultColumns('usuario@flowly.com');

      expect(board.ownerId, 'usuario@flowly.com');
      expect(board.columns.map((c) => c.name).toList(),
          ['Search', 'TODO', 'Doing', 'Done']);
      expect(board.tasks, isEmpty);
    });

    test('round-trip JSON conserva columnas, tareas y ownerId', () {
      final board = KanbanBoard.withDefaultColumns('usuario@flowly.com').copyWith(
        tasks: [
          KanbanTask(
            id: 't1',
            title: 'Hacer el kanban',
            columnId: 'doing',
            createdAt: DateTime(2026, 9, 17),
          ),
        ],
      );

      final restored = KanbanBoard.fromJson(board.toJson());

      expect(restored.ownerId, 'usuario@flowly.com');
      expect(restored.columns.length, 4);
      expect(restored.tasks.single.title, 'Hacer el kanban');
      expect(restored.tasks.single.columnId, 'doing');
      expect(restored.tasksFor('doing').single.title, 'Hacer el kanban');
    });

    test('fromJson tolera un JSON vacío', () {
      final board = KanbanBoard.fromJson(const {});

      expect(board.ownerId, '');
      expect(board.columns, isEmpty);
      expect(board.tasks, isEmpty);
    });
  });
}