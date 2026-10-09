/// Hábito que el usuario repite cada día.
///
/// Solo guarda identidad y nombre: el cumplimiento de cada día vive en
/// [HabitLog.completions], de modo que añadir un hábito no reescribe el
/// historial ya registrado.
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  final String id;
  final String title;

  /// Cuándo se añadió. Un día anterior a esta fecha no cuenta este hábito
  /// (ver [HabitLog.habitsOn]), para que crear un hábito hoy no ponga en rojo
  /// los días de ayer.
  final DateTime createdAt;

  Habit copyWith({String? id, String? title, DateTime? createdAt}) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, Object?> json) {
    final raw = json['createdAt'];
    return Habit(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt: raw is String
          ? DateTime.tryParse(raw) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Cómo se pinta una celda del calendario (ver mockup 03).
enum DayStatus {
  /// Día anterior con todos sus hábitos cumplidos: fondo verde.
  done,

  /// Día anterior al que le quedó algún hábito sin cumplir: fondo rojo.
  missed,

  /// Sin juicio todavía: el día de hoy aún no se ha cerrado, o el día es
  /// anterior a que existiera algún hábito. Fondo neutro.
  neutral,

  /// Día por venir: no se puede haber cumplido. Fondo apagado.
  future,

  /// Hueco de la rejilla (relleno inicial o día de otro mes): sin celda.
  empty,
}

/// Agregado raíz del registro de hábitos de Flowly.
///
/// Los checks se guardan como claves `"<id de hábito>@<AAAA-MM-DD>"` en un
/// conjunto plano: es un contrato JSON estable entre la fase local y la futura
/// API (ver `AGENTS.md`), y evita anidar mapas por día.
class HabitLog {
  const HabitLog({
    required this.ownerId,
    required this.habits,
    required this.completions,
  });

  /// Identifica al usuario al que pertenece el registro (email del perfil).
  final String ownerId;

  /// Hábitos del usuario, en el orden en que se añadieron.
  final List<Habit> habits;

  /// Claves de los checks marcados (ver `_checkKey`).
  final Set<String> completions;

  /// Registro inicial vacío de un usuario.
  factory HabitLog.empty(String ownerId) {
    return HabitLog(
      ownerId: ownerId,
      habits: const [],
      completions: const {},
    );
  }

  /// Clave de un check: el hábito y el día, en formato corto y sin zona
  /// horaria para que el mismo día sea la misma clave siempre.
  static String _checkKey(String habitId, DateTime day) =>
      '$habitId@${_isoDay(day)}';

  /// El día a las 00:00, que es la referencia de todas las comparaciones: el
  /// check se guarda por fecha, no por instante.
  static DateTime _dateOf(DateTime day) =>
      DateTime(day.year, day.month, day.day);

  static String _isoDay(DateTime day) {
    final date = _dateOf(day);
    final month = date.month.toString().padLeft(2, '0');
    final dayNumber = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$dayNumber';
  }

  /// Hábitos vigentes en [day]: los creados ese día o antes.
  ///
  /// Los días anteriores a la creación de un hábito no cuentan como
  /// incumplidos: son días sin datos, que el calendario pinta en neutro en
  /// lugar de marcarlos en rojo.
  List<Habit> habitsOn(DateTime day) {
    // Antes de la medianoche del día siguiente: así un hábito creado hoy a
    // media tarde sí cuenta para hoy.
    final endOfDay = DateTime(day.year, day.month, day.day + 1);
    return habits.where((h) => h.createdAt.isBefore(endOfDay)).toList();
  }

  /// Si el hábito [habitId] está marcado el [day].
  bool isDone(String habitId, DateTime day) =>
      completions.contains(_checkKey(habitId, day));

  /// Hábitos cumplidos de [day], contados solo entre los vigentes ese día.
  int doneCount(DateTime day) {
    return habitsOn(day).where((h) => isDone(h.id, day)).length;
  }

  /// Cuántos hábitos había ese día y cuántos están cumplidos.
  ({int total, int done}) progressOn(DateTime day) {
    final total = habitsOn(day);
    if (total.isEmpty) return (total: 0, done: 0);
    var done = 0;
    for (final habit in total) {
      if (isDone(habit.id, day)) done++;
    }
    return (total: total.length, done: done);
  }

  /// Si [day] tiene algún hábito vigente sin cumplir.
  ///
  /// Sin hábitos vigentes no hay nada pendiente: un día sin datos no cuenta
  /// como fallado (el calendario lo pinta en neutro).
  bool hasPendingOn(DateTime day) {
    final total = habitsOn(day).length;
    return total > 0 && doneCount(day) < total;
  }

  /// Estado de [day] respecto a [today], que decide el fondo de su celda.
  ///
  /// - Un día por venir no puede estar cumplido: apagado.
  /// - Sin hábitos vigentes no hay nada que juzgar: neutro.
  /// - Con todos los hábitos cumplidos: verde, también el día de hoy.
  /// - El día de hoy con algo pendiente sigue en neutro (aún puede
  ///   completarse), mientras que un día anterior con algo pendiente queda en
  ///   rojo: ya pasó y no se cumplió.
  DayStatus statusOf(DateTime day, DateTime today) {
    final date = _dateOf(day);
    final now = _dateOf(today);
    if (date.isAfter(now)) return DayStatus.future;
    if (habitsOn(date).isEmpty) return DayStatus.neutral;
    if (!hasPendingOn(date)) return DayStatus.done;
    return date == now ? DayStatus.neutral : DayStatus.missed;
  }

  /// Marca o desmarca el hábito [habitId] el [day].
  HabitLog toggle(String habitId, DateTime day) {
    final key = _checkKey(habitId, day);
    final next = completions.toSet();
    if (!next.remove(key)) next.add(key);
    return copyWith(completions: next);
  }

  /// Añade un hábito al final de la lista.
  HabitLog addHabit(Habit habit) {
    if (habits.any((h) => h.id == habit.id)) return this;
    return copyWith(habits: [...habits, habit]);
  }

  /// Elimina un hábito y todos sus checks.
  HabitLog removeHabit(String habitId) {
    return copyWith(
      habits: habits.where((h) => h.id != habitId).toList(),
      completions: completions
          .where((key) => !key.startsWith('$habitId@'))
          .toSet(),
    );
  }

  HabitLog copyWith({
    String? ownerId,
    List<Habit>? habits,
    Set<String>? completions,
  }) {
    return HabitLog(
      ownerId: ownerId ?? this.ownerId,
      habits: habits ?? this.habits,
      completions: completions ?? this.completions,
    );
  }

  Map<String, Object?> toJson() => {
        'ownerId': ownerId,
        'habits': habits.map((h) => h.toJson()).toList(),
        'completions': completions.toList(),
      };

  factory HabitLog.fromJson(Map<String, Object?> json) {
    return HabitLog(
      ownerId: json['ownerId'] as String? ?? '',
      habits: (json['habits'] as List<Object?>? ?? const <Object?>[])
          .map((h) => Habit.fromJson(h as Map<String, Object?>))
          .toList(),
      completions: (json['completions'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toSet(),
    );
  }
}