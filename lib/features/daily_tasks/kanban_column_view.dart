import 'package:flutter/material.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/kanban_task.dart';
import 'task_card.dart';

/// Datos del drag de una columna: identificador e índice de origen.
class _ColumnDragData {
  const _ColumnDragData({required this.columnId, required this.index});

  final String columnId;
  final int index;
}

/// Columna de un tablero kanban: cabecera (color + nombre + contador + menú)
/// y cuerpo con las tarjetas de tarea y el botón de añadir.
///
/// Actúa como `DragTarget<String>` para recibir tareas arrastradas y como
/// `DragTarget<_ColumnDragData>` para reordenar columnas soltadas sobre ella.
/// La cabecera es `LongPressDraggable`: arrastrarla por encima de otra columna
/// la mueve a la posición de la columna destino.
class KanbanColumnView extends StatelessWidget {
  const KanbanColumnView({
    super.key,
    required this.columnId,
    required this.columnName,
    required this.color,
    required this.tasks,
    required this.columnIndex,
    required this.onAddTask,
    required this.onRename,
    required this.onDelete,
    required this.onMoveTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onReorder,
  });

  final String columnId;
  final String columnName;
  final Color color;
  final List<KanbanTask> tasks;

  /// Posición (índice) de esta columna dentro del tablero.
  final int columnIndex;

  /// Pide crear una tarea en esta columna.
  final VoidCallback onAddTask;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  /// Mueve la tarea `taskId` a esta columna.
  final ValueChanged<String> onMoveTask;

  /// Abre el diálogo de edición de una tarea.
  final ValueChanged<KanbanTask> onEditTask;

  /// Pide confirmación y elimina una tarea.
  final ValueChanged<KanbanTask> onDeleteTask;

  /// Mueve la columna del índice `fromIndex` al índice `toIndex`.
  final void Function(int fromIndex, int toIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return DragTarget<_ColumnDragData>(
      onWillAcceptWithDetails: (details) => details.data.columnId != columnId,
      onAcceptWithDetails: (details) =>
          onReorder(details.data.index, columnIndex),
      builder: (context, columnCandidateData, rejectedData) {
        final isColumnOver = columnCandidateData.isNotEmpty;
        return DragTarget<String>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) => onMoveTask(details.data),
          builder: (context, taskCandidateData, rejectedData) {
            final isTaskOver = taskCandidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              width: 172,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isTaskOver || isColumnOver
                    ? palette.pinePale
                    : Colors.transparent,
                border: (isTaskOver || isColumnOver)
                    ? Border.all(color: palette.pine, width: 1.4)
                    : Border.all(color: Colors.transparent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildTaskList(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Palette.of(context);
    return LongPressDraggable<_ColumnDragData>(
      data: _ColumnDragData(columnId: columnId, index: columnIndex),
      delay: const Duration(milliseconds: 120),
      feedback: _buildHeaderFeedback(context),
      childWhenDragging: Opacity(opacity: 0.4, child: _buildHeaderRow(l10n, palette)),
      child: _buildHeaderRow(l10n, palette),
    );
  }

  /// Réplica compacta de la cabecera que sigue al puntero durante el drag.
  Widget _buildHeaderFeedback(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: palette.cardBg,
          border: Border.all(color: palette.pine, width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(
              columnName,
              style: styles.columnTitle,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 7),
            Text('${tasks.length}', style: styles.columnCount),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppLocalizations l10n, Palette palette) {
    final styles = AppTextStyles.from(palette);
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
            style: styles.columnTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
            color: palette.cardBg,
            border: Border.all(color: palette.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${tasks.length}', style: styles.columnCount),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, size: 18, color: palette.inkSoft),
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
              child: Text(l10n.columnRename, style: styles.columnTitle),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(l10n.columnDelete, style: styles.columnTitle),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTaskList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final styles = AppTextStyles.of(context);
    return [
      for (final task in tasks)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TaskCard(
            taskId: task.id,
            title: task.title,
            onEdit: () => onEditTask(task),
            onDelete: () => onDeleteTask(task),
          ),
        ),
      if (tasks.isEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              l10n.dailyTasksEmptyColumn,
              style: styles.emptyHint,
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
          child: Text(l10n.dailyTasksAddTask, style: styles.link),
        ),
      ),
    ];
  }
}