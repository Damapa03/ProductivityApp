import 'timer_phase_type.dart';

/// Fase de un temporizador.
class TimerPhase {
  const TimerPhase({
    required this.type,
    required this.durationSeconds,
  });

  /// Tipo de fase.
  final TimerPhaseType type;

  /// Duración en segundos.
  final int durationSeconds;
}
