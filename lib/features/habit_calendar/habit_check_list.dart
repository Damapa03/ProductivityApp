import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/habit.dart';

/// Lista checkeable de los hábitos de un día (ver mockup 03).
///
/// La tarjeta dice siempre de qué día son los checks y cuántos lleva hechos,
/// porque el calendario deja recorrer cualquier mes: sin ese dato no se sabría
/// si lo que se está marcando es hoy o un día pasado.
///
/// El día por venir se muestra en solo lectura: un hábito se cumple, no se
/// adelanta. Aun así se lista, para poder ver lo que viene.
class HabitCheckList extends StatelessWidget {
  const HabitCheckList({
    super.key,
    required this.day,
    required this.today,
    required this.habits,
    required this.isDone,
    required this.editable,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
  });

  /// Día a las 00:00 al que pertenecen los checks de la lista.
  final DateTime day;

  /// Hoy a las 00:00, para nombrar el día de hoy y no fecharlo entero.
  final DateTime today;

  /// Hábitos vigentes ese día, en el orden en que se añadieron.
  final List<Habit> habits;

  /// Si el hábito está cumplido el [day].
  final bool Function(Habit habit) isDone;

  /// Si se pueden marcar los checks (false en los días por venir).
  final bool editable;

  /// Notifica el hábito marcado o desmarcado en este día.
  final ValueChanged<Habit> onToggle;

  /// Notifica el hábito que se quiere eliminar.
  final ValueChanged<Habit> onDelete;

  /// Notifica que se quiere añadir un hábito.
  final VoidCallback onAdd;

  /// Separación entre la caja de check y su texto.
  static const double checkGap = 10;

  /// Alto de la franja de cada hábito (la separación vertical es su regla).
  static const double rowPadding = 9;

  static const double _padding = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final done = habits.where(isDone).length;

    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      // Recorta el trazo del resalte al radio de la tarjeta.
      clipBehavior: Clip.antiAlias,
      child: Container(
        key: const Key('habit-check-list'),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Heading(
              label: _dayLabel(context),
              done: done,
              total: habits.length,
            ),
            const SizedBox(height: 12),
            if (habits.isEmpty)
              Text(l10n.habitsEmpty, style: AppTextStyles.emptyHint)
            else
              for (var i = 0; i < habits.length; i++)
                _row(context, l10n, habits[i], i == 0),
            const SizedBox(height: 6),
            _AddButton(onTap: onAdd),
          ],
        ),
      ),
    );
  }

  /// Fecha del día de la lista: «Hoy» si es el día actual, y su fecha entera
  /// («miércoles, 1 de octubre») si es otro, con mayúscula inicial.
  String _dayLabel(BuildContext context) {
    if (isSameDay(day, today)) return AppLocalizations.of(context).habitsToday;

    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat('EEEE, d MMMM', locale).format(day);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  Widget _row(
    BuildContext context,
    AppLocalizations l10n,
    Habit habit,
    bool first,
  ) {
    final done = isDone(habit);

    return InkWell(
      onTap: editable ? () => onToggle(habit) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        key: ValueKey('habit-row-${habit.id}'),
        // La regla separa hábitos entre sí: la primera fila no lleva línea.
        decoration: first
            ? null
            : const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
        padding: const EdgeInsets.symmetric(vertical: rowPadding),
        child: Row(
          children: [
            _CheckBox(
              value: done,
              enabled: editable,
              onTap: () => onToggle(habit),
            ),
            const SizedBox(width: checkGap),
            Expanded(
              child: Text(
                habit.title,
                style: done
                    ? AppTextStyles.habitLabel
                    : AppTextStyles.habitLabelPending,
              ),
            ),
            _DeleteMenu(
              label: l10n.habitsDelete,
              habitTitle: habit.title,
              onDelete: () => onDelete(habit),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabecera de la tarjeta: título, día al que pertenecen los checks y el
/// contador de cuántos se han hecho.
class _Heading extends StatelessWidget {
  const _Heading({
    required this.label,
    required this.done,
    required this.total,
  });

  /// Nombre del día al que pertenecen los checks.
  final String label;
  final int done;
  final int total;

  static const double _titleGap = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.habitsTitle, style: AppTextStyles.habitCardTitle),
              const SizedBox(height: _titleGap),
              Text(label, style: AppTextStyles.habitDay),
            ],
          ),
        ),
        Text(
          key: const Key('habits-progress'),
          l10n.habitsProgress(done, total),
          style: AppTextStyles.habitProgress,
        ),
      ],
    );
  }
}

/// Caja de check del mockup: cuadrada de esquinas suaves, pine con el tick
/// cuando está marcada.
class _CheckBox extends StatelessWidget {
  const _CheckBox({
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  /// Si el hábito está cumplido.
  final bool value;

  /// Si se puede marcar (los días por venir no se pueden).
  final bool enabled;

  /// Notifica el cambio de estado.
  final VoidCallback? onTap;

  static const double size = 18;
  static const double radius = 5;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      enabled: enabled,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: value ? AppColors.pine : Colors.transparent,
            border: Border.all(
              color: value ? AppColors.pine : AppColors.line,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: value
              ? const Icon(Icons.check, size: 12, color: AppColors.paper)
              : null,
        ),
      ),
    );
  }
}

/// Menú de un hábito: por ahora, solo eliminarlo.
///
/// Se mantiene oculto tras elipsis, igual que las tareas del kanban, para no
/// competir con la fila del hábito, que es lo que se toca a diario.
class _DeleteMenu extends StatelessWidget {
  const _DeleteMenu({
    required this.label,
    required this.habitTitle,
    required this.onDelete,
  });

  /// Texto de la opción de eliminar.
  final String label;

  /// Nombre del hábito, para nombrar la opción accesiblemente.
  final String habitTitle;

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $habitTitle',
      button: true,
      // El botón solo aporta el glifo: el nombre accesible lo pone el
      // `Semantics` de arriba, para que se lea el hábito concreto que se
      // puede borrar.
      child: ExcludeSemantics(
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 16, color: AppColors.inkFaint),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 128),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (value) {
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Text(label, style: AppTextStyles.columnTitle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila para añadir un hábito nuevo.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        key: const Key('habits-add'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(l10n.habitsAddHabit, style: AppTextStyles.link),
        ),
      ),
    );
  }
}

/// Si dos fechas caen el mismo día, ignorando la hora.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;