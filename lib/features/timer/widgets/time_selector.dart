import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';

class TimeSelector extends StatelessWidget {
  const TimeSelector({
    super.key,
    required this.selectedBlock,
    required this.onBlockChanged,
  });

  final int selectedBlock;
  final ValueChanged<int> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      color: AppColors.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.timerTimes,
              style: AppTextStyles.fieldLabel.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 25,
                  label: const Text('25'),
                ),
                ButtonSegment<int>(
                  value: 45,
                  label: const Text('45'),
                ),
                ButtonSegment<int>(
                  value: 90,
                  label: const Text('90'),
                ),
              ],
              selected: {selectedBlock},
              onSelectionChanged: (Set<int> newSelection) {
                onBlockChanged(newSelection.first);
              },
              showSelectedIcon: false,
            ),
          ],
        ),
      ),
    );
  }
}
