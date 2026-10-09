import 'package:flutter/material.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/kanban_column.dart';
import '../../models/kanban_task.dart';
import 'task_menu_button.dart';

/// Estilos de la burbuja del estado, alineados con `palette.columnDots`
/// (ver mockup 02b): (fondo pale, texto deep). Se recorren en ciclo por
/// el índice de la columna.
List<(Color, Color)> _badgeStyles(Palette palette) => [
  (palette.columnGrayPale, palette.inkSoft), // Search
  (palette.rosePale, palette.roseDeep), // TODO
  (palette.amberPale, palette.amberDeep), // Doing
  (palette.pinePale, palette.pineDeep), // Done
];

/// Vista «Todas las tareas»: lista plana con todas las tareas del tablero.
///
/// Cada fila muestra el nombre de la tarea, una burbuja con el color del
/// estado (columna) y su nombre, y el menú de editar/eliminar.
class AllTasksView extends StatelessWidget {
  const AllTasksView({
    super.key,
    required this.columns,
    required this.tasks,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  /// Columnas del tablero (en orden), para resolver nombre y color del estado.
  final List<KanbanColumn> columns;

  /// Todas las tareas del tablero, sin agrupar.
  final List<KanbanTask> tasks;

  /// Abre el diálogo de edición de una tarea.
  final ValueChanged<KanbanTask> onEditTask;

  /// Pide confirmación y elimina una tarea.
  final ValueChanged<KanbanTask> onDeleteTask;

  int _columnIndex(String columnId) =>
      columns.indexWhere((c) => c.id == columnId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final styles = AppTextStyles.of(context);
    final palette = Palette.of(context);
    if (tasks.isEmpty) {
      return Center(
        child: Text(l10n.dailyTasksEmptyColumn, style: styles.emptyHint),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 28, 18),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final i = _columnIndex(task.columnId);
        final badgeStyles = _badgeStyles(palette);
        final (bg, fg) = badgeStyles[i >= 0 ? i % badgeStyles.length : 0];
        return _TaskListTile(
          title: task.title,
          statusName: i >= 0 ? columns[i].name : '',
          badgeBg: bg,
          badgeFg: fg,
          onEdit: () => onEditTask(task),
          onDelete: () => onDeleteTask(task),
        );
      },
    );
  }
}

/// Fila de la vista de lista: nombre, burbuja del estado y menú.
class _TaskListTile extends StatelessWidget {
  const _TaskListTile({
    required this.title,
    required this.statusName,
    required this.badgeBg,
    required this.badgeFg,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String statusName;
  final Color badgeBg;
  final Color badgeFg;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.cardBg,
        border: Border.all(color: palette.line),
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
                style: styles.taskText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusName,
              style: styles.statusBadge.copyWith(color: badgeFg),
            ),
          ),
          TaskMenuButton(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}