import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/kanban_column.dart';

/// Colección de diálogos del tablero kanban.
///
/// Todos devuelven `null` si se cancela.

const _dialogTitle = TextStyle(
  fontFamily: AppFonts.display,
  fontWeight: FontWeight.w700,
  fontSize: 20,
  height: 1.2,
);

/// Borrador de una tarea creada desde el diálogo con columna destino.
class TaskDraft {
  const TaskDraft({required this.title, required this.columnId});

  final String title;
  final String columnId;
}

/// Pide el nombre de una nueva columna.
Future<String?> showCreateColumnDialog(BuildContext context) {
  return _showNameDialog(
    context,
    title: AppLocalizations.of(context).dialogCreateColumnTitle,
    placeholder: AppLocalizations.of(context).dialogNamePlaceholder,
  );
}

/// Pide el nuevo nombre de una columna existente.
Future<String?> showRenameColumnDialog(
  BuildContext context, {
  required String currentName,
}) {
  return _showNameDialog(
    context,
    title: AppLocalizations.of(context).dialogRenameColumnTitle,
    current: currentName,
  );
}

/// Pide el título de una nueva tarea.
Future<String?> showCreateTaskDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return _showNameDialog(
    context,
    title: l10n.dialogCreateTaskTitle,
    placeholder: l10n.dialogTaskPlaceholder,
  );
}

/// Pide el título de una nueva tarea y la columna a la que irá.
///
/// Devuelve `null` si se cancela.
Future<TaskDraft?> showCreateTaskDialogWithColumn(
  BuildContext context, {
  required List<KanbanColumn> columns,
  String? initialColumnId,
}) async {
  final l10n = AppLocalizations.of(context);
  final styles = AppTextStyles.of(context);
  final controller = TextEditingController();
  var selected = initialColumnId ?? columns.first.id;

  void submit() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(TaskDraft(title: value, columnId: selected));
  }

  return showDialog<TaskDraft>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialogCreateTaskTitle, style: _dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
            style: styles.fieldInput,
            decoration: InputDecoration(
              hintText: l10n.dialogTaskPlaceholder,
              hintStyle: styles.fieldPlaceholder,
              counterText: '',
            ),
            onSubmitted: (_) => submit(),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: InputDecoration(
              labelText: l10n.dialogTaskColumnLabel,
              labelStyle: styles.fieldLabel,
            ),
            style: styles.fieldInput,
            isExpanded: true,
            items: [
              for (final column in columns)
                DropdownMenuItem(
                  value: column.id,
                  child: Text(column.name, style: styles.fieldInput),
                ),
            ],
            onChanged: (value) {
              if (value != null) selected = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: submit,
          child: Text(l10n.dialogConfirm),
        ),
      ],
    ),
  );
}

/// Pide el nuevo título de una tarea existente.
Future<String?> showEditTaskDialog(
  BuildContext context, {
  required String currentTitle,
}) {
  final l10n = AppLocalizations.of(context);
  return _showNameDialog(
    context,
    title: l10n.dialogEditTaskTitle,
    current: currentTitle,
    placeholder: l10n.dialogTaskPlaceholder,
  );
}

/// Confirma la eliminación de una columna y sus tareas.
Future<bool> showDeleteColumnDialog(
  BuildContext context, {
  required String columnName,
  required int taskCount,
}) async {
  final l10n = AppLocalizations.of(context);
  final styles = AppTextStyles.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialogDeleteColumnTitle, style: _dialogTitle),
      content: Text(
        l10n.dialogDeleteColumnBody(columnName, taskCount),
        style: styles.subline,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.dialogConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Confirma la eliminación de una tarea.
Future<bool> showDeleteTaskDialog(
  BuildContext context, {
  required String taskTitle,
}) async {
  final l10n = AppLocalizations.of(context);
  final styles = AppTextStyles.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialogDeleteTaskTitle, style: _dialogTitle),
      content: Text(
        l10n.dialogDeleteTaskBody(taskTitle),
        style: styles.subline,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.dialogConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<String?> _showNameDialog(
  BuildContext context, {
  required String title,
  String? current,
  String? placeholder,
}) {
  final l10n = AppLocalizations.of(context);
  final styles = AppTextStyles.of(context);
  final controller = TextEditingController(text: current ?? '');
  final formKey = GlobalKey<FormState>();

  void submit() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: _dialogTitle),
      content: Form(
        key: formKey,
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          style: styles.fieldInput,
          decoration: InputDecoration(
            hintText: placeholder ?? l10n.dialogNamePlaceholder,
            hintStyle: styles.fieldPlaceholder,
            counterText: '',
          ),
          onSubmitted: (_) => submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: submit,
          child: Text(l10n.dialogConfirm),
        ),
      ],
    ),
  );
}