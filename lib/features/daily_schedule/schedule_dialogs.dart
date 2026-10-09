import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/palette.dart';
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
///
/// [selectableDays] añade una fila de chips para elegir a qué día va la franja:
/// solo la vista semanal lo pasa, con los siete días de la semana que está
/// viendo, de modo que desde el plan del día el campo del día se sigue
/// deduciendo del hueco tocado y no se puede cambiar.
Future<ScheduleEventDraft?> showScheduleEventDialog(
  BuildContext context, {
  required DateTime defaultStart,
  ScheduleEvent? initial,
  List<DateTime>? selectableDays,
}) {
  return showDialog<ScheduleEventDraft>(
    context: context,
    builder: (context) => _ScheduleEventDialog(
      defaultStart: defaultStart,
      initial: initial,
      selectableDays: selectableDays,
    ),
  );
}

/// Menú inferior con las opciones de una franja: Editar / Eliminar.
///
/// Devuelve `null` si se cierra sin elegir.
Future<ScheduleEventAction?> showScheduleEventOptions(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final palette = Palette.of(context);
  final styles = AppTextStyles.of(context);
  return showModalBottomSheet<ScheduleEventAction>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit_outlined, color: palette.pine),
            title: Text(l10n.taskEdit, style: styles.fieldInput),
            onTap: () =>
                Navigator.of(context).pop(ScheduleEventAction.edit),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: palette.rose),
            title: Text(l10n.taskDelete, style: styles.fieldInput),
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
  final styles = AppTextStyles.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialogDeleteTaskTitle, style: _dialogTitle),
      content: Text(
        l10n.dialogDeleteTaskBody(eventTitle),
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

class _ScheduleEventDialog extends StatefulWidget {
  const _ScheduleEventDialog({
    required this.defaultStart,
    this.initial,
    this.selectableDays,
  });

  /// Fecha base y hora por defecto para el inicio de la franja.
  final DateTime defaultStart;

  /// Franja a editar; `null` para crear una nueva.
  final ScheduleEvent? initial;

  /// Días entre los que se puede elegir el de la franja. Si es `null` no se
  /// muestra el selector y el día queda fijado por el hueco que se tocó.
  final List<DateTime>? selectableDays;

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

  /// Lleva la franja a [day] conservando la hora de inicio y su duración.
  ///
  /// Se mueve el inicio a la misma hora del día elegido y el fin se recalcula
  /// desde la duración previa. Así una franja 10:00–11:00 pasa al miércoles
  /// siendo 10:00–11:00, y una que cruza medianoche mantiene su salto al día
  /// siguiente en lugar de collapsing a una duración negativa.
  void _selectDay(DateTime day) {
    final duration = _end.difference(_start);
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      _start.hour,
      _start.minute,
    );
    setState(() {
      _start = start;
      _end = start.add(duration);
      _error = null;
    });
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
    final styles = AppTextStyles.of(context);

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
            style: styles.fieldInput,
            decoration: InputDecoration(
              labelText: l10n.scheduleEventNameLabel,
              labelStyle: styles.fieldLabel,
              hintText: l10n.scheduleEventNamePlaceholder,
              hintStyle: styles.fieldPlaceholder,
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
          if (widget.selectableDays case final days?) ...[
            const SizedBox(height: 14),
            Text(l10n.scheduleDayLabel.toUpperCase(), style: styles.fieldLabel),
            const SizedBox(height: 6),
            _DayChipRow(
              days: days,
              selected: _start,
              onSelected: _selectDay,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: styles.fieldError),
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

/// Fila de chips para elegir el día de la franja (solo vista semanal).
///
/// Replica el aspecto de la cabecera de la rejilla semanal: sigla encima y
/// número debajo. El chip del día elegido se rellena con `pineDeep` y su texto
/// pasa a claro, el mismo criterio que usa el conmutador Día / Semana; hoy se
/// distingue con el tinte `pinePale` cuando no es el día elegido, para que se
/// sepa de un vistazo dónde está el día actual.
class _DayChipRow extends StatelessWidget {
  const _DayChipRow({
    required this.days,
    required this.selected,
    required this.onSelected,
  });

  /// Días ofrecidos, en orden.
  final List<DateTime> days;

  /// Día al que pertenece la franja ahora mismo.
  final DateTime selected;

  /// Notifica el día elegido.
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      children: [
        for (final day in days) ...[
          if (day != days.first) const SizedBox(width: 6),
          Expanded(
            child: _DayChip(
              // Índice de posición, no el día: la clave es estable entre
              // franja y franja.
              key: ValueKey('schedule-day-chip-${days.indexOf(day)}'),
              name: DateFormat.E(locale).format(day).toUpperCase(),
              number: '${day.day}',
              isSelected: _sameDay(day, selected),
              isToday: _sameDay(day, today),
              onTap: () => onSelected(day),
            ),
          ),
        ],
      ],
    );
  }
}

/// Un chip de día: la sigla, el número y el toque.
class _DayChip extends StatelessWidget {
  const _DayChip({
    super.key,
    required this.name,
    required this.number,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final String name;
  final String number;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    final background = isSelected
        ? palette.pineDeep
        : isToday
        ? palette.pinePale
        : Colors.transparent;
    final foreground = isSelected ? palette.onPrimary : palette.ink;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(
            color: isSelected ? palette.pineDeep : palette.line,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: styles.weekDayName.copyWith(color: foreground),
            ),
            const SizedBox(height: 2),
            Text(
              number,
              style: styles.weekDayNumber.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

/// Si [a] y [b] caen en el mismo día, sin mirar la hora.
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

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
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat.Hm(locale).format(time);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: styles.fieldLabel),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: palette.line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text(formatted, style: styles.fieldInput)),
                Icon(
                  Icons.schedule_outlined,
                  size: 18,
                  color: palette.inkFaint,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}