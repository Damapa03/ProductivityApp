import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';

/// Tarjeta de tarea arrastrable (long-press) para moverla entre columnas.
///
/// `data` del drag: el id de la tarea (String).
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.taskId,
    required this.title,
    this.draggable = true,
  });

  final String taskId;
  final String title;
  final bool draggable;

  static const double _feedbackWidth = 160;

  Widget _buildCard({required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(title, style: AppTextStyles.taskText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(opacity: 1);

    if (!draggable) return card;

    return LongPressDraggable<String>(
      data: taskId,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: _feedbackWidth, child: _buildCard(opacity: 0.9)),
      ),
      childWhenDragging: _buildCard(opacity: 0.4),
      child: card,
    );
  }
}