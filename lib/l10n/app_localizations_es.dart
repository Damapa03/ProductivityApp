// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Flowly';

  @override
  String get loginHeadline => 'Buenas, de nuevo.';

  @override
  String get loginSubline => 'Retoma tus tareas donde las dejaste.';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginSubmit => 'Iniciar sesión';

  @override
  String get loginOrContinueWith => 'o continúa con';

  @override
  String get loginNewToFlowly => '¿Nuevo en Flowly? ';

  @override
  String get loginCreateAccount => 'Crear una cuenta';

  @override
  String get registerHeadline => 'Crea tu cuenta.';

  @override
  String get registerSubline => 'Empieza a crear hábitos que perduran.';

  @override
  String get registerSubmit => 'Crear cuenta';

  @override
  String registerWelcome(String name) {
    return 'Bienvenido a Flowly, $name 🎉';
  }

  @override
  String get fieldNameLabel => 'NOMBRE';

  @override
  String get fieldNamePlaceholder => 'Tu nombre completo';

  @override
  String get fieldEmailLabel => 'EMAIL';

  @override
  String get fieldEmailPlaceholder => 'tu@flowly.com';

  @override
  String get fieldEmailInvalid => 'Introduce un email válido.';

  @override
  String get fieldPasswordLabel => 'CONTRASEÑA';

  @override
  String get fieldPasswordPlaceholder => '8+ caracteres';

  @override
  String get fieldPasswordRequired => 'La contraseña es obligatoria.';

  @override
  String get fieldPasswordMinLength => 'Usa al menos 8 caracteres.';

  @override
  String get fieldConfirmPasswordLabel => 'CONFIRMAR CONTRASEÑA';

  @override
  String get fieldConfirmPasswordPlaceholder => 'Repite tu contraseña';

  @override
  String get fieldPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get socialGoogle => 'Google';

  @override
  String get socialApple => 'Apple';

  @override
  String get dailyTasksTitle => 'Tareas diarias';

  @override
  String get dailyTasksNewColumn => 'Nueva columna';

  @override
  String get dailyTasksAddColumn => 'Añadir columna';

  @override
  String get dailyTasksAddTask => '+ Añadir tarea';

  @override
  String get dailyTasksEmptyColumn => 'Sin tareas todavía';

  @override
  String get dailyTasksViewByStatus => 'Por estado';

  @override
  String get dailyTasksViewAll => 'Todas las tareas';

  @override
  String get scheduleTitle => 'Plan de hoy';

  @override
  String get scheduleWeekTitle => 'Esta semana';

  @override
  String get scheduleViewDay => 'Día';

  @override
  String get scheduleViewWeek => 'Semana';

  @override
  String get scheduleCreateEventTitle => 'Nueva tarea';

  @override
  String get scheduleEventNameLabel => 'Tarea';

  @override
  String get scheduleEventNamePlaceholder => 'Qué vas a hacer en esta franja';

  @override
  String get scheduleStartLabel => 'Inicio';

  @override
  String get scheduleEndLabel => 'Fin';

  @override
  String get scheduleInvalidRange =>
      'La hora de fin debe ser posterior al inicio.';

  @override
  String get columnRename => 'Renombrar';

  @override
  String get columnDelete => 'Eliminar';

  @override
  String get taskEdit => 'Editar';

  @override
  String get taskDelete => 'Eliminar';

  @override
  String get dialogCreateColumnTitle => 'Nueva columna';

  @override
  String get dialogRenameColumnTitle => 'Renombrar columna';

  @override
  String get dialogCreateTaskTitle => 'Nueva tarea';

  @override
  String get dialogNameLabel => 'Nombre';

  @override
  String get dialogNamePlaceholder => 'Nombre de la columna';

  @override
  String get dialogTaskPlaceholder => 'Describe la tarea';

  @override
  String get dialogConfirm => 'Confirmar';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogDeleteColumnTitle => 'Eliminar columna';

  @override
  String dialogDeleteColumnBody(String column, int count) {
    return 'Se eliminará la columna «$column» y sus $count tareas. Esta acción no se puede deshacer.';
  }

  @override
  String get dialogEditTaskTitle => 'Editar tarea';

  @override
  String get dialogDeleteTaskTitle => 'Eliminar tarea';

  @override
  String dialogDeleteTaskBody(String task) {
    return 'Se eliminará la tarea «$task». Esta acción no se puede deshacer.';
  }

  @override
  String get dialogTaskColumnLabel => 'Columna';

  @override
  String get dialogTaskNoColumns => 'Añade una columna antes de crear tareas.';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navHabits => 'Hábitos';

  @override
  String get navSchedule => 'Agenda';

  @override
  String get navFocus => 'Timer';

  @override
  String get navBlackList => 'Lista negra';

  @override
  String get navProfile => 'Perfil';

  @override
  String get blackListTitle => 'Lista negra';

  @override
  String get blackListHint => 'Empieza a escribir…';

  @override
  String get comingSoonTitle => 'Próximamente';

  @override
  String get comingSoonBody => 'Esta pantalla todavía no está disponible.';
}
