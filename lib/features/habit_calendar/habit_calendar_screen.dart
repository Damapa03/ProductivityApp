import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/text_styles.dart';
import '../../data/habit_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/habit.dart';
import '../../widgets/step_navigator.dart';
import 'habit_check_list.dart';
import 'habit_dialogs.dart';
import 'month_grid.dart';

/// Pantalla «Hábitos»: calendario mensual con el registro de cada día y la
/// lista de checks del día elegido (ver mockup 03).
///
/// Arriba va el mes que se está mirando, con sus flechas; debajo, la rejilla
/// donde cada día se pinta según lo que se cumplió (ver [DayStatus]). Abajo,
/// los hábitos del día que se ha tocado en el calendario, que es de donde sale
/// el color de su celda: marcar un hábito de un día pasado cambia esa celda,
/// y tocar otro día cambia la lista.
///
/// Los datos se guardan en local con cada cambio (ver [LocalHabitRepository]),
/// como el resto de pantallas; no hay migración a API todavía.
class HabitCalendarScreen extends StatefulWidget {
  const HabitCalendarScreen({super.key, required this.ownerId, this.today});

  /// Email del perfil con el que se asocia la persistencia del registro.
  final String ownerId;

  /// Día actual a las 00:00. Por defecto, hoy; los tests lo fijan para poder
  /// comprobar sin fechas los colores de un día pasado.
  final DateTime? today;

  @override
  State<HabitCalendarScreen> createState() => _HabitCalendarScreenState();
}

class _HabitCalendarScreenState extends State<HabitCalendarScreen> {
  final HabitRepository _repository = LocalHabitRepository();
  HabitLog? _log;

  /// Primer día del mes visible; las flechas lo mueven de uno en uno.
  late DateTime _month = _firstOfMonth(_today);

  /// Día al que pertenecen los checks de la lista de abajo.
  late DateTime _selectedDay = _today;

  /// Hoy a las 00:00: la referencia para saber qué días aún no se han cerrado.
  late final DateTime _today = _midnight(widget.today ?? DateTime.now());

  static DateTime _midnight(DateTime day) =>
      DateTime(day.year, day.month, day.day);

  static DateTime _firstOfMonth(DateTime day) =>
      DateTime(day.year, day.month);

  /// Si el mes visible es el de hoy.
  bool get _isCurrentMonth =>
      _month.year == _today.year && _month.month == _today.month;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var log = await _repository.load(widget.ownerId);
    if (log == null) {
      log = HabitLog.empty(widget.ownerId);
      await _repository.save(widget.ownerId, log);
    }
    if (!mounted) return;
    setState(() => _log = log);
  }

  /// Escribe el registro nuevo en local y lo refleja en pantalla.
  Future<void> _persist(HabitLog next) async {
    await _repository.save(widget.ownerId, next);
    if (!mounted) return;
    setState(() => _log = next);
  }

  /// Retrocede o avanza un mes, saltando de año al cambiar de mes en enero o
  /// diciembre.
  void _stepMonth(int months) {
    setState(() => _month = DateTime(_month.year, _month.month + months));
  }

  /// Vuelve al mes y al día de hoy desde lo que se esté mirando.
  void _goToToday() {
    setState(() {
      _month = _firstOfMonth(_today);
      _selectedDay = _today;
    });
  }

  /// Elige el día cuyos hábitos muestra la lista.
  void _selectDay(DateTime day) {
    setState(() => _selectedDay = day);
  }

  /// Marca o desmarca un hábito del día seleccionado y guarda el cambio.
  Future<void> _toggle(Habit habit) async {
    final log = _log;
    if (log == null) return;
    await _persist(log.toggle(habit.id, _selectedDay));
  }

  /// Añade un hábito con el nombre que devuelva el diálogo.
  Future<void> _addHabit() async {
    final log = _log;
    if (log == null) return;
    final title = await showAddHabitDialog(context);
    if (title == null) return;
    final habit = Habit(
      // El microsegundo evita repetir id si se añaden dos hábitos seguidos.
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    await _persist(log.addHabit(habit));
  }

  /// Elimina un hábito y todos sus checks, previa confirmación.
  Future<void> _deleteHabit(Habit habit) async {
    final log = _log;
    if (log == null) return;
    final confirmed = await showDeleteHabitDialog(context, habit);
    if (!confirmed) return;
    await _persist(log.removeHabit(habit.id));
  }

  /// Nombre del mes visible con su año («Septiembre 2026»), con mayúscula
  /// inicial como el resto de fechas de la app.
  String _monthTitle(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat('MMMM y', locale).format(_month);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final log = _log;

    return Scaffold(
      body: SafeArea(
        child: log == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MonthHeader(
                    title: _monthTitle(context),
                    onPrevious: () => _stepMonth(-1),
                    onNext: () => _stepMonth(1),
                    onToday: _isCurrentMonth ? null : _goToToday,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MonthGrid(
                          month: _month,
                          today: _today,
                          selectedDay: _selectedDay,
                          statusOf: (day) => log.statusOf(day, _today),
                          onTapDay: _selectDay,
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: HabitLegend(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // La lista lleva su propio margen: el calendario arriba no
                  // necesita scrolls, pero los hábitos pueden ser muchos.
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: HabitCheckList(
                        day: _selectedDay,
                        today: _today,
                        habits: log.habitsOn(_selectedDay),
                        isDone: (habit) => log.isDone(habit.id, _selectedDay),
                        // Un hábito se cumple el día que llega, no antes.
                        editable: !_selectedDay.isAfter(_today),
                        onToggle: _toggle,
                        onDelete: _deleteHabit,
                        onAdd: _addHabit,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Cabecera con el mes que se está mirando y las flechas para recorrerlos.
///
/// El mes va centrado de verdad ([Stack] con el texto al centro y la
/// navegación anclada a la izquierda), así que no se desplaza cuando la
/// píldora «Hoy» aparece o desaparece al moverse de mes.
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.title,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  /// Mes y año que se muestra, p. ej. «Septiembre 2026».
  final String title;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Vuelta al mes de hoy; `null` cuando ya se está en él.
  final VoidCallback? onToday;

  /// Mismo margen lateral y aire superior que la cabecera del resto de
  /// pantallas (ver `ScreenHeader`).
  static const EdgeInsets padding = EdgeInsets.fromLTRB(24, 12, 24, 0);

  static const double bottomSpacing = 18;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(title, style: AppTextStyles.monthTitle),
              Align(
                alignment: Alignment.centerLeft,
                child: StepNavigator(
                  onPrevious: onPrevious,
                  onNext: onNext,
                  onToday: onToday,
                  // Las flechas mueven meses aquí, no días como en la agenda.
                  previousLabel: l10n.habitsPreviousMonth,
                  nextLabel: l10n.habitsNextMonth,
                  todayLabel: l10n.habitsToday,
                ),
              ),
            ],
          ),
          const SizedBox(height: bottomSpacing),
        ],
      ),
    );
  }
}