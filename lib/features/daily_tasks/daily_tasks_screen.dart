import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../data/kanban_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/kanban_board.dart';
import '../../models/kanban_column.dart';
import '../../models/kanban_task.dart';
import 'add_task_fab.dart';
import 'all_tasks_view.dart';
import 'daily_tasks_dialogs.dart';
import 'kanban_column_view.dart';

/// Pantalla "Daily Tasks": kanban con columnas y tareas asociadas al usuario.
class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key, required this.ownerId});

  /// Email del perfil con el que se asocia la persistencia del tablero.
  final String ownerId;

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  final KanbanRepository _repository = LocalKanbanRepository();
  final ScrollController _boardScrollController = ScrollController();
  KanbanBoard? _board;

  /// `false` = vista «Por estado» (kanban); `true` = «Todas las tareas».
  bool _showAllTasks = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _boardScrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    var board = await _repository.load(widget.ownerId);
    if (board == null) {
      board = KanbanBoard.withDefaultColumns(widget.ownerId);
      await _repository.save(widget.ownerId, board);
    }
    if (!mounted) return;
    setState(() => _board = board);
  }

  Future<void> _persist(KanbanBoard next) async {
    await _repository.save(widget.ownerId, next);
    if (!mounted) return;
    setState(() => _board = next);
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _createColumn() async {
    final name = await showCreateColumnDialog(context);
    if (name == null || !mounted) return;
    final board = _board;
    if (board == null) return;
    final column = KanbanColumn(id: _newId(), name: name);
    await _persist(
      board.copyWith(columns: [...board.columns, column]),
    );
  }

  Future<void> _reorderColumns(int fromIndex, int toIndex) async {
    final board = _board;
    if (board == null || fromIndex == toIndex) return;
    await _persist(board.moveColumn(fromIndex, toIndex));
  }

  Future<void> _renameColumn(KanbanColumn column) async {
    final name = await showRenameColumnDialog(context, currentName: column.name);
    if (name == null || !mounted) return;
    final board = _board;
    if (board == null) return;
    await _persist(
      board.copyWith(
        columns: [
          for (final c in board.columns)
            c.id == column.id ? c.copyWith(name: name) : c,
        ],
      ),
    );
  }

  Future<void> _deleteColumn(KanbanColumn column) async {
    final board = _board;
    if (board == null) return;
    final count = board.tasksFor(column.id).length;
    final confirmed = await showDeleteColumnDialog(
      context,
      columnName: column.name,
      taskCount: count,
    );
    if (!confirmed || !mounted) return;
    await _persist(
      board.copyWith(
        columns: board.columns.where((c) => c.id != column.id).toList(),
        tasks: board.tasks.where((t) => t.columnId != column.id).toList(),
      ),
    );
  }

  Future<void> _createTask(KanbanColumn column) async {
    final title = await showCreateTaskDialog(context);
    if (title == null || !mounted) return;
    final board = _board;
    if (board == null) return;
    final task = KanbanTask(
      id: _newId(),
      title: title,
      columnId: column.id,
      createdAt: DateTime.now(),
    );
    await _persist(board.copyWith(tasks: [...board.tasks, task]));
  }

  /// Añade una tarea desde el botón flotante: pide título y columna destino.
  Future<void> _addTaskFromFab() async {
    final board = _board;
    if (board == null) return;
    if (board.columns.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).dialogTaskNoColumns),
          ),
        );
      return;
    }
    final draft = await showCreateTaskDialogWithColumn(
      context,
      columns: board.columns,
    );
    if (draft == null || !mounted) return;
    final task = KanbanTask(
      id: _newId(),
      title: draft.title,
      columnId: draft.columnId,
      createdAt: DateTime.now(),
    );
    await _persist(board.copyWith(tasks: [...board.tasks, task]));
  }

  Future<void> _editTask(KanbanTask task) async {
    final title = await showEditTaskDialog(context, currentTitle: task.title);
    if (title == null || title == task.title || !mounted) return;
    final board = _board;
    if (board == null) return;
    await _persist(
      board.copyWith(
        tasks: [
          for (final t in board.tasks)
            t.id == task.id ? t.copyWith(title: title) : t,
        ],
      ),
    );
  }

  Future<void> _deleteTask(KanbanTask task) async {
    final board = _board;
    if (board == null) return;
    final confirmed = await showDeleteTaskDialog(context, taskTitle: task.title);
    if (!confirmed || !mounted) return;
    await _persist(
      board.copyWith(
        tasks: board.tasks.where((t) => t.id != task.id).toList(),
      ),
    );
  }

  Future<void> _moveTask(String taskId, String toColumnId) async {
    final board = _board;
    if (board == null) return;
    var changed = false;
    final tasks = board.tasks.map((t) {
      if (t.id == taskId && t.columnId != toColumnId) {
        changed = true;
        return t.copyWith(columnId: toColumnId);
      }
      return t;
    }).toList();
    if (!changed) return;
    await _persist(board.copyWith(tasks: tasks));
  }

  String _formattedDate(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat('EEEE, d MMMM', locale).format(DateTime.now());
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final board = _board;

    return Scaffold(
      body: SafeArea(
        child: board == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    // Margen superior para que la fecha no quede pegada
                    // al borde (en navegador el SafeArea no aporta aire), y
                    // lateral de 24 para alinear el título con el selector de
                    // vista y con el tablero.
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: _buildHeader(context, l10n),
                  ),
                  const SizedBox(height: 18),
                  _ViewSwitcher(
                    showAllTasks: _showAllTasks,
                    onChanged: (all) => setState(() => _showAllTasks = all),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: _showAllTasks
                        ? AllTasksView(
                            columns: board.columns,
                            tasks: board.tasks,
                            onEditTask: _editTask,
                            onDeleteTask: _deleteTask,
                          )
                        : _buildBoard(board),
                  ),
                ],
              ),
      ),
      floatingActionButton: AddTaskFab(onPressed: _addTaskFromFab),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    // Sin flecha de retroceso: la pantalla ya no es una ruta encima del login,
    // es una pestaña del shell.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formattedDate(context), style: AppTextStyles.eyebrow),
        const SizedBox(height: 3),
        Text(l10n.dailyTasksTitle, style: AppTextStyles.screenTitle),
      ],
    );
  }

  Widget _buildBoard(KanbanBoard board) {
    return Scrollbar(
      controller: _boardScrollController,
      thumbVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: _boardScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 0, 28, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < board.columns.length; i++) ...[
              KanbanColumnView(
                key: ValueKey(board.columns[i].id),
                columnId: board.columns[i].id,
                columnName: board.columns[i].name,
                color: AppColors.columnDots[i % AppColors.columnDots.length],
                tasks: board.tasksFor(board.columns[i].id),
                columnIndex: i,
                onAddTask: () => _createTask(board.columns[i]),
                onRename: () => _renameColumn(board.columns[i]),
                onDelete: () => _deleteColumn(board.columns[i]),
                onMoveTask: (taskId) =>
                    _moveTask(taskId, board.columns[i].id),
                onEditTask: _editTask,
                onDeleteTask: _deleteTask,
                onReorder: _reorderColumns,
              ),
              const SizedBox(width: 14),
            ],
            // Botón compacto «+» pegado a la última columna.
            Align(
              alignment: Alignment.topCenter,
              child: _AddColumnButton(onPressed: _createColumn),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

/// Selector de vista del tablero: «Por estado» / «Todas las tareas».
///
/// Es una segmentada: solo una opción activa a la vez y tocar la opción ya
/// activa no hace nada (ver mockup 02b).
class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({
    required this.showAllTasks,
    required this.onChanged,
  });

  /// `true` si la vista activa es «Todas las tareas».
  final bool showAllTasks;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildOption(
            context,
            label: l10n.dailyTasksViewByStatus,
            active: !showAllTasks,
            onTap: () => onChanged(false),
          ),
          _buildOption(
            context,
            label: l10n.dailyTasksViewAll,
            active: showAllTasks,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        // Tocar la opción activa es un no-op.
        onTap: active ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.pineDeep : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.segmented.copyWith(
              color: active ? const Color(0xFFF3F4EF) : AppColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón compacto para añadir una columna al final del tablero kanban.
///
/// Sin fondo ni texto: solo un icono «+» pegado a la última columna.
class _AddColumnButton extends StatelessWidget {
  const _AddColumnButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: l10n.dailyTasksAddColumn,
      child: IconButton(
        key: const Key('add-column-button'),
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: AppColors.pine),
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      ),
    );
  }
}