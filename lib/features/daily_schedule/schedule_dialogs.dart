import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/schedule_event.dart';

/// Diálogos del horario de agenda (franjas horarias).
///
/// Todos devuelven `null` si se cancelan.

const _dialogTitle = TextStyle(
  fontFamily: AppFonts.display,
  fontWeight: FontWeight.w700,
  fontSize: 20,
  height: 1.2,
);

/// Borrador de una franja creada o editada desde el diálogo.
class ScheduleEventDraft {
  const ScheduleEventDraft({
    required this.title,
    required this.start,
    required this.end,
  });

  final String title;
  final DateTime start;
  final DateTime end;
}

/// Acciones posibles sobre una franja existente.
enum ScheduleEventAction { edit, delete }

/// Pide los datos de una franja: nombre, hora de inicio y hora de fin.
///
/// Con [initial] pre-rellena el diálogo para editar; sin él, parte desde
/// [defaultStart] con una duración de una hora. Devuelve `null` si se cancela.
Future<ScheduleEventDraft?> showScheduleEventDialog(
  BuildContext context, {
  required DateTime defaultStart,
  ScheduleEvent? initial,
}) {
  return showDialog<ScheduleEventDraft>(
    context: context,
    builder: (context) =>
        _ScheduleEventDialog(defaultStart: defaultStart, initial: initial),
  );
}

/// Menú inferior con las opciones de una franja: Editar / Eliminar.
///
/// Devuelve `null` si se cierra sin elegir.
Future<ScheduleEventAction?> showScheduleEventOptions(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<ScheduleEventAction>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.pine),
            title: Text(l10n.taskEdit, style: AppTextStyles.fieldInput),
            onTap: () =>
                Navigator.of(context).pop(ScheduleEventAction.edit),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.rose),
            title: Text(l10n.taskDelete, style: AppTextStyles.fieldInput),
            onTap: () =>
                Navigator.of(context).pop(ScheduleEventAction.delete),
          ),
        ],
      ),
    ),
  );
}

/// Confirma el borrado de una franja.
Future<bool> showDeleteScheduleEventDialog(
  BuildContext context, {
  required String eventTitle,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialogDeleteTaskTitle, style: _dialogTitle),
      content: Text(
        l10n.dialogDeleteTaskBody(eventTitle),
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

class _ScheduleEventDialog extends StatefulWidget {
  const _ScheduleEventDialog({required this.defaultStart, this.initial});

  /// Fecha base y hora por defecto para el inicio de la franja.
  final DateTime defaultStart;

  /// Franja a editar; `null` para crear una nueva.
  final ScheduleEvent? initial;

  @override
  State<_ScheduleEventDialog> createState() => _ScheduleEventDialogState();
}

class _ScheduleEventDialogState extends State<_ScheduleEventDialog> {
  late final TextEditingController _controller;
  late DateTime _start;
  late DateTime _end;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _controller = TextEditingController(text: initial?.title ?? '');
    _start = initial?.start ?? widget.defaultStart;
    _end = initial?.end ?? widget.defaultStart.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Hora de [time] aplicada sobre la fecha base de [day].
  DateTime _timeOn(DateTime day, TimeOfDay time) {
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> _pick({required bool isStart}) async {
    final current = isStart ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start = _timeOn(_start, picked);
      } else {
        _end = _timeOn(_end, picked);
      }
      _error = null;
    });
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    if (!_end.isAfter(_start)) {
      setState(() => _error = l10n.scheduleInvalidRange);
      return;
    }
    Navigator.of(context)
        .pop(ScheduleEventDraft(title: title, start: _start, end: _end));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.scheduleCreateEventTitle, style: _dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 60,
            style: AppTextStyles.fieldInput,
            decoration: InputDecoration(
              labelText: l10n.scheduleEventNameLabel,
              labelStyle: AppTextStyles.fieldLabel,
              hintText: l10n.scheduleEventNamePlaceholder,
              hintStyle: AppTextStyles.fieldPlaceholder,
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: l10n.scheduleStartLabel,
                  time: _start,
                  onTap: () => _pick(isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: l10n.scheduleEndLabel,
                  time: _end,
                  onTap: () => _pick(isStart: false),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.fieldError),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: _submit,
          child: Text(l10n.dialogConfirm),
        ),
      ],
    );
  }
}

/// Campo de hora del diálogo: abre [showTimePicker] al tocarlo.
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final DateTime time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat.Hm(locale).format(time);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text(formatted, style: AppTextStyles.fieldInput)),
                const Icon(
                  Icons.schedule_outlined,
                  size: 18,
                  color: AppColors.inkFaint,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}