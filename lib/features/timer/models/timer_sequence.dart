import 'timer_mode.dart';
import 'timer_phase.dart';
import 'timer_phase_type.dart';

/// Genera secuencias de fases para el temporizador Flowly.
class TimerSequence {
  TimerSequence({
    required this.mode,
    required this.block,
  });

  /// Modo actual.
  final TimerMode mode;

  /// Bloque seleccionado: 25, 45 o 90.
  final int block;

  /// Índice del ciclo para el bloque 45 (0-based).
  /// Ciclo: 0→10min, 1→10min, 2→15min, luego vuelve a 0.
  static int cycleIndex45 = 0;

  /// Número de ejecuciones completadas del bloque 45.
  static int completed45Count = 0;

  /// Indica si ya se ejecutó el bloque 90 en modo trabajo/estudio.
  static bool block90Completed = false;

  /// Genera la secuencia completa para el bloque actual.
  List<TimerPhase> generate() {
    switch (block) {
      case 25:
        return _generate25();
      case 45:
        return _generate45();
      case 90:
        return _generate90();
      default:
        return _generate25();
    }
  }

  List<TimerPhase> _generate25() {
    final phases = <TimerPhase>[];
    // Modo trabajo: (25T + 5D) × 2 → (25T + 15D) × 1
    if (mode == TimerMode.work) {
      // Primera ronda
      phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 25 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: 5 * 60));
      // Segunda ronda
      phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 25 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: 5 * 60));
      // Tercera ronda
      phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 25 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: 15 * 60));
      return phases;
    } else {
      // Modo estudio: (25T + 5D + 5R) × 2 → (25T + 15D + 5R) × 1
      // Primera ronda
      phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 25 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: 5 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.review, durationSeconds: 5 * 60));
      // Segunda ronda
      phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 25 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: 5 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.review, durationSeconds: 5 * 60));
      // Tercera ronda
      phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 25 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: 15 * 60));
      phases.add(const TimerPhase(type: TimerPhaseType.review, durationSeconds: 5 * 60));
      return phases;
    }
  }

  List<TimerPhase> _generate45() {
    final phases = <TimerPhase>[];
    // Determinar duración de descanso según ciclo: 0→10, 1→10, 2→15
    final breakMinutes = cycleIndex45 == 2 ? 15 : 10;
    phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 45 * 60));
    phases.add(TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: breakMinutes * 60));
    if (mode == TimerMode.study) {
      phases.add(const TimerPhase(type: TimerPhaseType.review, durationSeconds: 5 * 60));
    }
    return phases;
  }

  List<TimerPhase> _generate90() {
    final phases = <TimerPhase>[];
    phases.add(const TimerPhase(type: TimerPhaseType.work, durationSeconds: 90 * 60));
    phases.add(const TimerPhase(type: TimerPhaseType.breakTime, durationSeconds: 10 * 60));
    if (mode == TimerMode.study) {
      phases.add(const TimerPhase(type: TimerPhaseType.review, durationSeconds: 5 * 60));
    }
    return phases;
  }

  /// Notifica que se completó la secuencia actual.
  void onCompleted() {
    if (block == 45) {
      completed45Count++;
      cycleIndex45 = completed45Count % 3;
    } else if (block == 90) {
      block90Completed = true;
    }
  }

  /// Obtiene el siguiente bloque tras completar 90.
  static int nextBlockAfter90() {
    return 45;
  }

  /// Obtiene el siguiente modo recomendado (igual al actual).
  static TimerMode nextModeAfter90() {
    return TimerMode.values[0]; // no usado, se mantiene
  }
}
