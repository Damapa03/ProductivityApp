/// Franja horaria de la agenda Flowly.
///
/// Representa una tarea designada a un intervalo del día (p. ej. «Deep work»
/// de 10:00 a 12:00). Es independiente del tablero kanban de Daily Tasks: la
/// agenda tiene sus propios bloques, modelo y repositorio.
class ScheduleEvent {
  const ScheduleEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  final String id;
  final String title;

  /// Instante de inicio (incluye la fecha del día al que pertenece).
  final DateTime start;

  /// Instante de fin; siempre posterior (o igual) a [start].
  final DateTime end;

  Duration get duration => end.difference(start);

  ScheduleEvent copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory ScheduleEvent.fromJson(Map<String, Object?> json) {
    DateTime parse(String key) {
      final raw = json[key];
      return raw is String ? DateTime.tryParse(raw) ?? DateTime.now() : DateTime.now();
    }

    return ScheduleEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      start: parse('start'),
      end: parse('end'),
    );
  }
}