import 'package:flutter/material.dart';

import '../../data/schedule_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/daily_schedule.dart';
import '../../models/schedule_event.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/segmented_control.dart';
import '../../widgets/step_navigator.dart';
import 'day_timeline.dart';
import 'schedule_dialogs.dart';
import 'week_timeline.dart';

/// Pantalla «Daily Schedule»: plan de un día sobre una línea de tiempo con sus
/// 24 horas (ver mockup 04) y, en modo «Semana», la rejilla de los siete días
/// con las mismas funciones (ver mockup 04b).
///
/// Comparte cabecera con el resto de pantallas ([ScreenHeader]), con un
/// selector «Día / Semana» y unas flechas ([StepNavigator]) que mueven el día
/// que se está mirando o la semana entera, según el modo. Ambas vistas leen y
/// escriben el mismo horario: al tocar un hueco se crea una franja horaria
/// (tarea de agenda, independiente del kanban) con la fecha y la hora de esa
/// celda, y al tocar una franja se ofrece editarla o eliminarla.
class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({
    super.key,
    required this.ownerId,
    this.entryTick = 0,
  });

  /// Email del perfil con el que se asocia la persistencia del horario.
  final String ownerId;

  /// Marca de entrada a la pantalla: el `HomeShell` la incrementa cada vez que
  /// se selecciona la pestaña Agenda, de modo que el scroll de la rejilla
  /// reenfoca la hora actual en cada visita (el IndexedStack conserva la
  /// posición entre visitas).
  final int entryTick;

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  final ScheduleRepository _repository = LocalScheduleRepository();
  final ScrollController _dayScrollController = ScrollController();
  final ScrollController _weekScrollController = ScrollController();
  DailySchedule? _schedule;

  /// `true` si la vista activa es la rejilla semanal («Semana»).
  bool _showWeek = false;

  /// Día que se está mirando, a las 00:00.
  ///
  /// Toda la pantalla se deriva de aquí en lugar de de hoy: la vista de un día
  /// muestra sus franjas y la rejilla semanal la semana a la que pertenece, de
  /// modo que las flechas de la cabecera bastan con mover esta fecha (un día en
  /// modo día, siete en modo semanal). Al volver a entrar en la pestaña se
  /// vuelve a hoy.
  late DateTime _focusedDay = _midnight(DateTime.now());

  /// Hoy a las 00:00, la referencia para saber si lo que se mira es hoy.
  static DateTime _today() => _midnight(DateTime.now());

  static DateTime _midnight(DateTime day) =>
      DateTime(day.year, day.month, day.day);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DailyScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nueva entrada a la pestaña Agenda: se vuelve al día de hoy y la rejilla
    // reenfoca la hora actual (el IndexedStack conserva la posición entre
    // visitas, pero el sitio en el calendario se reinicia).
    if (widget.entryTick != oldWidget.entryTick) {
      _focusedDay = _today();
      _scrollToCurrentHour();
    }
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    _weekScrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    var schedule = await _repository.load(widget.ownerId);
    if (schedule == null) {
      schedule = DailySchedule.empty(widget.ownerId);
      await _repository.save(widget.ownerId, schedule);
    }
    if (!mounted) return;
    setState(() => _schedule = schedule);
    // La rejilla se crea en el siguiente frame (cuando el horario ya está
    // cargado): ahí sí hay lienzo sobre el que desplazarse.
    _scrollToCurrentHour();
  }

  Future<void> _persist(DailySchedule next) async {
    await _repository.save(widget.ownerId, next);
    if (!mounted) return;
    setState(() => _schedule = next);
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Los siete días de la semana visible, para que el diálogo permita elegir
  /// el día. Solo tiene sentido en la vista semanal: en el plan del día el
  /// día lo fija el hueco tocado y no hay nada que escoger.
  List<DateTime>? get _selectableDays {
    if (!_showWeek) return null;
    return [
      for (var day = 0; day < WeekTimeline.daysCount; day++)
        _weekStart.add(Duration(days: day)),
    ];
  }

  /// Lunes de la semana que se está mirando.
  DateTime get _weekStart => WeekTimeline.startOfWeek(_focusedDay);

  /// Si el día mostrado es hoy, y por tanto no hace falta atajo para volver.
  bool get _isToday =>
      _focusedDay.year == _today().year &&
      _focusedDay.month == _today().month &&
      _focusedDay.day == _today().day;

  /// Avanza o retrocede en el tiempo: un día en el plan del día, una semana
  /// entera en la rejilla (sumar siete conserva el día de la semana, así que
  /// la semana salta exacta).
  void _step(int days) {
    setState(() => _focusedDay = _focusedDay.add(Duration(days: days)));
    // La vista recién pintada arranca arriba del todo, así que se reenfoca la
    // hora actual para no dejar al usuario en la medianoche.
    _scrollToCurrentHour();
  }

  /// Vuelve al día de hoy desde el que se esté mirando.
  void _goToToday() {
    if (_isToday) return;
    _step(_today().difference(_focusedDay).inDays);
  }

  /// Crea una franja con inicio en [start] (hora del hueco tocado).
  Future<void> _createEvent(DateTime start) async {
    final schedule = _schedule;
    if (schedule == null) return;
    final draft = await showScheduleEventDialog(
      context,
      defaultStart: start,
      selectableDays: _selectableDays,
    );
    if (draft == null || !mounted) return;
    final event = ScheduleEvent(
      id: _newId(),
      title: draft.title,
      start: draft.start,
      end: draft.end,
    );
    await _persist(schedule.copyWith(events: [...schedule.events, event]));
  }

  /// Menú de una franja tocada: editar o eliminar.
  Future<void> _openEvent(ScheduleEvent event) async {
    final action = await showScheduleEventOptions(context);
    if (action == null || !mounted) return;
    switch (action) {
      case ScheduleEventAction.edit:
        await _editEvent(event);
      case ScheduleEventAction.delete:
        await _deleteEvent(event);
    }
  }

  Future<void> _editEvent(ScheduleEvent event) async {
    final schedule = _schedule;
    if (schedule == null) return;
    final draft = await showScheduleEventDialog(
      context,
      defaultStart: event.start,
      initial: event,
      selectableDays: _selectableDays,
    );
    if (draft == null || !mounted) return;
    final updated = event.copyWith(
      title: draft.title,
      start: draft.start,
      end: draft.end,
    );
    await _persist(
      schedule.copyWith(
        events: [
          for (final e in schedule.events) e.id == event.id ? updated : e,
        ],
      ),
    );
  }

  Future<void> _deleteEvent(ScheduleEvent event) async {
    final schedule = _schedule;
    if (schedule == null) return;
    final confirmed = await showDeleteScheduleEventDialog(
      context,
      eventTitle: event.title,
    );
    if (!confirmed || !mounted) return;
    await _persist(
      schedule.copyWith(
        events: schedule.events.where((e) => e.id != event.id).toList(),
      ),
    );
  }

  /// Conmuta entre la vista de un día y la rejilla de la semana.
  void _selectView(int index) {
    setState(() => _showWeek = index == 1);
    // La vista recién creada arranca arriba del todo: se reenfoca la hora
    // actual para no dejar al usuario en la medianoche.
    _scrollToCurrentHour();
  }

  /// Tras el primer frame, desplaza la rejilla hacia la hora actual (con dos
  /// horas de contexto arriba), limitado al máximo del recorrido.
  ///
  /// Se aplica a las dos vistas, cada una con la altura de su hora, y solo si
  /// ya está construida.
  void _scrollToCurrentHour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpToCurrentHour(_dayScrollController, DayTimeline.hourHeight);
      _jumpToCurrentHour(_weekScrollController, WeekTimeline.hourHeight);
    });
  }

  void _jumpToCurrentHour(ScrollController controller, double hourHeight) {
    if (!controller.hasClients) return;
    final now = DateTime.now();
    final target = ((now.hour - 2) * hourHeight).clamp(0.0, double.infinity);
    final position = controller.position;
    controller.jumpTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final schedule = _schedule;
    final focusedDay = _focusedDay;
    final focusedEvents =
        schedule?.eventsOn(focusedDay) ?? const <ScheduleEvent>[];
    // Lunes de la semana que se está mirando y el lunes siguiente como límite
    // exclusivo.
    final weekStart = _weekStart;
    final nextWeek = weekStart.add(
      const Duration(days: WeekTimeline.daysCount),
    );
    final weekEvents =
        schedule?.eventsBetween(weekStart, nextWeek) ?? const <ScheduleEvent>[];

    return Scaffold(
      body: SafeArea(
        child: schedule == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera compartida con el resto de pantallas, con el mismo
                  // margen que el selector y la rejilla. En modo Semana el
                  // título pasa a «Esta semana» y la línea de arriba muestra el
                  // rango de días en lugar de la fecha del día. A la derecha
                  // del título van las flechas para mover el día o la semana,
                  // con el atajo de «Hoy» solo cuando no se está en hoy.
                  ScreenHeader(
                    title: _showWeek
                        ? l10n.scheduleWeekTitle
                        : l10n.scheduleTitle,
                    date: _showWeek ? null : focusedDay,
                    eyebrow: _showWeek
                        ? WeekTimeline.rangeLabel(context, weekStart)
                        : null,
                    trailing: StepNavigator(
                      isWeekView: _showWeek,
                      onPrevious: () => _step(_showWeek ? -7 : -1),
                      onNext: () => _step(_showWeek ? 7 : 1),
                      onToday: _isToday ? null : _goToToday,
                    ),
                  ),
                  SegmentedControl(
                    options: [l10n.scheduleViewDay, l10n.scheduleViewWeek],
                    activeIndex: _showWeek ? 1 : 0,
                    onSelected: _selectView,
                  ),
                  const SizedBox(height: 14),
                  // Las dos vistas comparten los gestos: solo cambia la rejilla
                  // sobre la que se dibujan las franjas.
                  Expanded(
                    child: _showWeek
                        ? WeekTimeline(
                            controller: _weekScrollController,
                            weekStart: weekStart,
                            events: weekEvents,
                            onCreateEvent: _createEvent,
                            onTapEvent: _openEvent,
                          )
                        : DayTimeline(
                            controller: _dayScrollController,
                            events: focusedEvents,
                            // La marca de la hora actual solo tiene sentido
                            // sobre el día en el que ocurre.
                            showNowLine: _isToday,
                            onCreateEvent: _createEvent,
                            onTapEvent: _openEvent,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}