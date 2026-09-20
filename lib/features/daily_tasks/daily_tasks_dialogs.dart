import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';

/// Colección de diálogos del tablero kanban.
///
/// Todos devuelven `null` si se cancela.

const _dialogTitle = TextStyle(
  fontFamily: AppFonts.display,
  fontWeight: FontWeight.w700,
  fontSize: 20,
  height: 1.2,
);

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
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialogDeleteColumnTitle, style: _dialogTitle),
      content: Text(
        l10n.dialogDeleteColumnBody(columnName, taskCount),
        style: AppTextStyles.subline,
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
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialogDeleteTaskTitle, style: _dialogTitle),
      content: Text(
        l10n.dialogDeleteTaskBody(taskTitle),
        style: AppTextStyles.subline,
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
          style: AppTextStyles.fieldInput,
          decoration: InputDecoration(
            hintText: placeholder ?? l10n.dialogNamePlaceholder,
            hintStyle: AppTextStyles.fieldPlaceholder,
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