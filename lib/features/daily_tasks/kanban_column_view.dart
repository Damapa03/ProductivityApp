import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/kanban_task.dart';
import 'task_card.dart';

/// Columna de un tablero kanban: cabecera (color + nombre + contador + menú)
/// y cuerpo con las tarjetas de tarea y el botón de añadir.
///
/// Actúa como `DragTarget<String>` para recibir tareas arrastradas.
class KanbanColumnView extends StatelessWidget {
  const KanbanColumnView({
    super.key,
    required this.columnId,
    required this.columnName,
    required this.color,
    required this.tasks,
    required this.onAddTask,
    required this.onRename,
    required this.onDelete,
    required this.onMoveTask,
  });

  final String columnId;
  final String columnName;
  final Color color;
  final List<KanbanTask> tasks;

  /// Pide crear una tarea en esta columna.
  final VoidCallback onAddTask;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  /// Mueve la tarea `taskId` a esta columna.
  final ValueChanged<String> onMoveTask;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onMoveTask(details.data),
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: 172,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isOver ? AppColors.pinePale : Colors.transparent,
            border: isOver
                ? Border.all(color: AppColors.pine, width: 1.4)
                : Border.all(color: Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              ..._buildTaskList(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 7),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            columnName,
            style: AppTextStyles.columnTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${tasks.length}', style: AppTextStyles.columnCount),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, size: 18, color: AppColors.inkSoft),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 128),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (value) {
            if (value == 'rename') onRename();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: Text(l10n.columnRename, style: AppTextStyles.columnTitle),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(l10n.columnDelete, style: AppTextStyles.columnTitle),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTaskList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      for (final task in tasks)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TaskCard(taskId: task.id, title: task.title),
        ),
      if (tasks.isEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              l10n.dailyTasksEmptyColumn,
              style: AppTextStyles.emptyHint,
            ),
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: onAddTask,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
          ),
          child: Text(l10n.dailyTasksAddTask, style: AppTextStyles.link),
        ),
      ),
    ];
  }
}