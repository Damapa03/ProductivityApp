import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/timer_mode.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final TimerMode selectedMode;
  final ValueChanged<TimerMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);

    return Card(
      color: palette.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: palette.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.timerMode,
              style: styles.fieldLabel.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TimerMode>(
              segments: [
                ButtonSegment<TimerMode>(
                  value: TimerMode.work,
                  label: Text(l10n.timerModeWork),
                ),
                ButtonSegment<TimerMode>(
                  value: TimerMode.study,
                  label: Text(l10n.timerModeStudy),
                ),
              ],
              selected: {selectedMode},
              onSelectionChanged: (Set<TimerMode> newSelection) {
                onModeChanged(newSelection.first);
              },
              showSelectedIcon: false,
            ),
          ],
        ),
      ),
    );
  }
}
