import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/timer_controller.dart';
import '../models/timer_phase_type.dart';

class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.state,
  });

  final TimerState state;

  @override
  Widget build(BuildContext context) {
    final phase = state.currentPhase;
    final minutes = (state.remainingSeconds / 60).floor();
    final seconds = state.remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 240,
              height: 240,
              child: CircularProgressIndicator(
                value: 1.0 - state.progress,
                strokeWidth: 12,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColor(phase?.type),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getPhaseLabel(context, phase?.type),
                  style: AppTextStyles.subline.copyWith(
                    color: AppColors.ink.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Color _getColor(TimerPhaseType? type) {
    switch (type) {
      case TimerPhaseType.work:
        return AppColors.pine;
      case TimerPhaseType.breakTime:
        return AppColors.amber;
      case TimerPhaseType.review:
        return AppColors.rose;
      case null:
        return AppColors.pine;
    }
  }

  String _getPhaseLabel(BuildContext context, TimerPhaseType? type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case TimerPhaseType.work:
        return l10n.timerPhaseWork;
      case TimerPhaseType.breakTime:
        return l10n.timerPhaseBreak;
      case TimerPhaseType.review:
        return l10n.timerPhaseReview;
      case null:
        return l10n.timerPhaseWork;
    }
  }
}
