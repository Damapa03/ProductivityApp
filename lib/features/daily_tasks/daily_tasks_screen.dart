import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../data/kanban_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/kanban_board.dart';
import '../../models/kanban_column.dart';
import '../../models/kanban_task.dart';
import 'daily_tasks_dialogs.dart';
import 'kanban_column_view.dart';

/// Colores del punto de cada columna, derivados del índice (ver mockup 02).
const _columnDots = <Color>[
  Color(0xFF9AA79E), // Search (gris)
  AppColors.rose, // TODO
  AppColors.amber, // Doing
  AppColors.pine, // Done
];

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
  KanbanBoard? _board;

  @override
  void initState() {
    super.initState();
    _load();
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
                  _buildHeader(context, l10n),
                  const SizedBox(height: 18),
                  Expanded(child: _buildBoard(board)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createColumn,
        backgroundColor: AppColors.pineDeep,
        foregroundColor: const Color(0xFFF3F4EF),
        tooltip: l10n.dailyTasksNewColumn,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.inkSoft,
          ),
          tooltip: l10n.appName,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formattedDate(context), style: AppTextStyles.eyebrow),
              const SizedBox(height: 3),
              Text(l10n.dailyTasksTitle, style: AppTextStyles.screenTitle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(KanbanBoard board) {
    return SingleChildScrollView(
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
              color: _columnDots[i % _columnDots.length],
              tasks: board.tasksFor(board.columns[i].id),
              onAddTask: () => _createTask(board.columns[i]),
              onRename: () => _renameColumn(board.columns[i]),
              onDelete: () => _deleteColumn(board.columns[i]),
              onMoveTask: (taskId) => _moveTask(taskId, board.columns[i].id),
            ),
            const SizedBox(width: 14),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}