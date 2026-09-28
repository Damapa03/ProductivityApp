import 'schedule_event.dart';

/// Agregado raíz del horario de agenda diaria de Flowly.
///
/// Contiene las franjas del usuario. El contrato JSON es estable entre la fase
/// local y la futura API (ver `AGENTS.md`). Cada franja guarda su propia fecha
/// (`start`), de modo que la vista semanal futura podrá filtrar por rango sin
/// cambiar el modelo.
class DailySchedule {
  const DailySchedule({required this.ownerId, required this.events});

  /// Identifica al usuario al que pertenece el horario (email del perfil).
  final String ownerId;
  final List<ScheduleEvent> events;

  /// Franjas que caen en el día [day], comparando solo la fecha.
  List<ScheduleEvent> eventsOn(DateTime day) {
    return events
        .where((e) =>
            e.start.year == day.year &&
            e.start.month == day.month &&
            e.start.day == day.day)
        .toList();
  }

  DailySchedule copyWith({String? ownerId, List<ScheduleEvent>? events}) {
    return DailySchedule(
      ownerId: ownerId ?? this.ownerId,
      events: events ?? this.events,
    );
  }

  /// Horario inicial vacío para un usuario.
  factory DailySchedule.empty(String ownerId) {
    return DailySchedule(ownerId: ownerId, events: const []);
  }

  Map<String, Object?> toJson() => {
        'ownerId': ownerId,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory DailySchedule.fromJson(Map<String, Object?> json) {
    return DailySchedule(
      ownerId: json['ownerId'] as String? ?? '',
      events: (json['events'] as List<Object?>? ?? const <Object?>[])
          .map((e) => ScheduleEvent.fromJson(e as Map<String, Object?>))
          .toList(),
    );
  }
}