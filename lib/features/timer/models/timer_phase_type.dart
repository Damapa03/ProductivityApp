enum TimerPhaseType {
  work,
  breakTime,
  review,
}

/// Convierte [TimerPhaseType] a texto para UI.
extension TimerPhaseTypeX on TimerPhaseType {
  String label(dynamic l10n) {
    switch (this) {
      case TimerPhaseType.work:
        return l10n.timerPhaseWork;
      case TimerPhaseType.breakTime:
        return l10n.timerPhaseBreak;
      case TimerPhaseType.review:
        return l10n.timerPhaseReview;
    }
  }
}
