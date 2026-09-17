import 'kanban_column.dart';
import 'kanban_task.dart';

/// Agregado raíz del tablero kanban diario de Flowly.
///
/// Contiene las columnas (ordenadas) y las tareas. El contrato JSON es estable
/// entre la fase local y la futura API (ver `AGENTS.md`).
class KanbanBoard {
  const KanbanBoard({
    required this.ownerId,
    required this.columns,
    required this.tasks,
  });

  /// Identifica al usuario que creó el tablero (email del perfil).
  final String ownerId;
  final List<KanbanColumn> columns;
  final List<KanbanTask> tasks;

  List<KanbanTask> tasksFor(String columnId) =>
      tasks.where((t) => t.columnId == columnId).toList();

  KanbanBoard copyWith({
    String? ownerId,
    List<KanbanColumn>? columns,
    List<KanbanTask>? tasks,
  }) {
    return KanbanBoard(
      ownerId: ownerId ?? this.ownerId,
      columns: columns ?? this.columns,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, Object?> toJson() => {
        'ownerId': ownerId,
        'columns': columns.map((c) => c.toJson()).toList(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  /// Crea el tablero inicial con las columnas por defecto, en este orden:
  /// Search, TODO, Doing, Done.
  factory KanbanBoard.withDefaultColumns(String ownerId) {
    return KanbanBoard(
      ownerId: ownerId,
      columns: const [
        KanbanColumn(id: 'search', name: 'Search'),
        KanbanColumn(id: 'todo', name: 'TODO'),
        KanbanColumn(id: 'doing', name: 'Doing'),
        KanbanColumn(id: 'done', name: 'Done'),
      ],
      tasks: const [],
    );
  }

  factory KanbanBoard.fromJson(Map<String, Object?> json) {
    return KanbanBoard(
      ownerId: json['ownerId'] as String? ?? '',
      columns: (json['columns'] as List<Object?>? ?? const <Object?>[])
          .map((e) => KanbanColumn.fromJson(e as Map<String, Object?>))
          .toList(),
      tasks: (json['tasks'] as List<Object?>? ?? const <Object?>[])
          .map((e) => KanbanTask.fromJson(e as Map<String, Object?>))
          .toList(),
    );
  }
}