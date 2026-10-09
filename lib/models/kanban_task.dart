/// Tarea de un tablero kanban Flowly.
class KanbanTask {
  const KanbanTask({
    required this.id,
    required this.title,
    required this.columnId,
    required this.createdAt,
  });

  final String id;
  final String title;

  /// Columna a la que pertenece la tarea.
  final String columnId;
  final DateTime createdAt;

  KanbanTask copyWith({
    String? id,
    String? title,
    String? columnId,
    DateTime? createdAt,
  }) {
    return KanbanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      columnId: columnId ?? this.columnId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'columnId': columnId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory KanbanTask.fromJson(Map<String, Object?> json) {
    final raw = json['createdAt'];
    return KanbanTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      columnId: json['columnId'] as String? ?? '',
      createdAt: raw is String
          ? DateTime.tryParse(raw) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}