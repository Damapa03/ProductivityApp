/// Columna de un tablero kanban Flowly.
///
/// El color no se persiste: se deriva del índice de la columna en la UI.
class KanbanColumn {
  const KanbanColumn({required this.id, required this.name});

  final String id;
  final String name;

  KanbanColumn copyWith({String? id, String? name}) {
    return KanbanColumn(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, Object?> toJson() => {'id': id, 'name': name};

  factory KanbanColumn.fromJson(Map<String, Object?> json) {
    return KanbanColumn(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}