import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';

/// Menú contextual de una tarea: opciones «Editar» y «Eliminar».
///
/// Compartido por la tarjeta del kanban y por las filas de la vista de lista.
class TaskMenuButton extends StatelessWidget {
  const TaskMenuButton({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.iconSize = 16,
    this.iconColor = AppColors.inkFaint,
  });

  /// Abre el diálogo de edición de la tarea.
  final VoidCallback onEdit;

  /// Pide confirmación y elimina la tarea.
  final VoidCallback onDelete;

  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: iconSize, color: iconColor),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 128),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Text(l10n.taskEdit, style: AppTextStyles.columnTitle),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(l10n.taskDelete, style: AppTextStyles.columnTitle),
        ),
      ],
    );
  }
}