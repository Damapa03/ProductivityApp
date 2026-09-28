import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/text_styles.dart';
import '../../data/schedule_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/daily_schedule.dart';
import '../../models/schedule_event.dart';
import '../../widgets/segmented_control.dart';
import 'day_timeline.dart';
import 'schedule_dialogs.dart';

/// Pantalla «Daily Schedule»: plan del día actual sobre una línea de tiempo
/// con sus 24 horas (ver mockup 04).
///
/// Comparte cabecera con Daily Tasks (fecha + título) y añade un selector
/// «Día / Semana» donde solo «Día» está implementada. Al tocar un hueco se
/// crea una franja horaria (tarea de agenda, independiente del kanban) y al
/// tocar una franja se ofrece editarla o eliminarla.
class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({super.key, required this.ownerId});

  /// Email del perfil con el que se asocia la persistencia del horario.
  final String ownerId;

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  final ScheduleRepository _repository = LocalScheduleRepository();
  final ScrollController _scrollController = ScrollController();
  DailySchedule? _schedule;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    // La línea de tiempo se crea en el siguiente frame (cuando el horario ya
    // está cargado): ahí sí hay lienzo sobre el que desplazarse.
    _scrollToCurrentHour();
  }

  Future<void> _persist(DailySchedule next) async {
    await _repository.save(widget.ownerId, next);
    if (!mounted) return;
    setState(() => _schedule = next);
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Crea una franja con inicio en [start] (hora del hueco tocado).
  Future<void> _createEvent(DateTime start) async {
    final schedule = _schedule;
    if (schedule == null) return;
    final draft = await showScheduleEventDialog(context, defaultStart: start);
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

  /// Tras el primer frame, desplaza la línea de tiempo hacia la hora actual
  /// (con dos horas de contexto arriba), limitado al máximo del recorrido.
  void _scrollToCurrentHour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final now = DateTime.now();
      final target = ((now.hour - 2) * DayTimeline.hourHeight)
          .clamp(0.0, double.infinity);
      final position = _scrollController.position;
      _scrollController.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    });
  }

  /// Fecha del día localizada («lunes, 28 septiembre») con mayúscula inicial.
  String _formattedDate(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat('EEEE, d MMMM', locale).format(DateTime.now());
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final schedule = _schedule;
    final today = DateTime.now();
    final todayEvents = schedule?.eventsOn(today) ?? const <ScheduleEvent>[];

    return Scaffold(
      body: SafeArea(
        child: schedule == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    // Mismo margen superior y lateral que Daily Tasks para
                    // alinear la cabecera con el selector y la línea de tiempo.
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formattedDate(context),
                          style: AppTextStyles.eyebrow,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.scheduleTitle,
                          style: AppTextStyles.screenTitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Selector «Día / Semana»: solo «Día» está implementada;
                  // «Semana» está presente pero sin funcionalidad.
                  SegmentedControl(
                    options: [l10n.scheduleViewDay, l10n.scheduleViewWeek],
                    activeIndex: 0,
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: DayTimeline(
                      controller: _scrollController,
                      events: todayEvents,
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