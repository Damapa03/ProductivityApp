enum TimerMode {
  work,
  study,
}

/// Convierte [TimerMode] a texto para UI.
extension TimerModeX on TimerMode {
  String label(dynamic l10n) {
    switch (this) {
      case TimerMode.work:
        return l10n.timerModeWork;
      case TimerMode.study:
        return l10n.timerModeStudy;
    }
  }
}
