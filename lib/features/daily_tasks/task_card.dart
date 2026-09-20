import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';

/// Tarjeta de tarea arrastrable (long-press) para moverla entre columnas.
///
/// `data` del drag: el id de la tarea (String).
/// Incluye un menú contextual (···) para editar o eliminar la tarea.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.taskId,
    required this.title,
    this.draggable = true,
    this.onEdit,
    this.onDelete,
  });

  final String taskId;
  final String title;
  final bool draggable;

  /// Abre el diálogo de edición de la tarea.
  final VoidCallback? onEdit;

  /// Pide confirmación y elimina la tarea.
  final VoidCallback? onDelete;

  static const double _feedbackWidth = 160;

  Widget _buildCard(BuildContext context, {required double opacity}) {
    final l10n = AppLocalizations.of(context);
    final hasMenu = onEdit != null || onDelete != null;
    return Opacity(
      opacity: opacity,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(12, 12, hasMenu ? 4 : 12, 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  title,
                  style: AppTextStyles.taskText,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (hasMenu)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 16,
                  color: AppColors.inkFaint,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 128),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.taskEdit, style: AppTextStyles.columnTitle),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      l10n.taskDelete,
                      style: AppTextStyles.columnTitle,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context, opacity: 1);

    if (!draggable) return card;

    return LongPressDraggable<String>(
      data: taskId,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: _feedbackWidth,
          child: _buildCard(context, opacity: 0.9),
        ),
      ),
      childWhenDragging: _buildCard(context, opacity: 0.4),
      child: card,
    );
  }
}