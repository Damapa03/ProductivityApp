import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/habit.dart';

/// Diálogos de los hábitos: crear uno nuevo y confirmar su borrado.
///
/// Los dos devuelven `null`/`false` si se cancelan.

/// Título de los diálogos, con el mismo cuerpo que el resto de la app.
const _dialogTitle = TextStyle(
  fontFamily: AppFonts.display,
  fontWeight: FontWeight.w700,
  fontSize: 20,
  height: 1.2,
);

/// Pide el nombre de un hábito nuevo.
///
/// Devuelve el nombre ya recortado, o `null` si se cancela o se deja en
/// blanco (no se crea un hábito sin nombre).
Future<String?> showAddHabitDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _AddHabitDialog(),
  );
}

/// Confirma el borrado de un hábito y de todos sus checks.
Future<bool> showDeleteHabitDialog(
  BuildContext context,
  Habit habit,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.habitsDeleteTitle, style: _dialogTitle),
      content: Text(
        l10n.habitsDeleteBody(habit.title),
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
          child: Text(l10n.habitsDelete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Diálogo con un único campo: el nombre del hábito.
class _AddHabitDialog extends StatefulWidget {
  const _AddHabitDialog();

  @override
  State<_AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<_AddHabitDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.habitsAddHabitTitle, style: _dialogTitle),
      content: TextField(
        key: const Key('habit-title-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        style: AppTextStyles.fieldInput,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.habitsAddHabitLabel,
          labelStyle: AppTextStyles.fieldLabel,
          hintText: l10n.habitsAddHabitPlaceholder,
          hintStyle: AppTextStyles.fieldPlaceholder,
          counterText: '',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: _submit,
          child: Text(l10n.habitsAdd),
        ),
      ],
    );
  }
}