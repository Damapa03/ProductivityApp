import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Flowly'**
  String get appName;

  /// No description provided for @loginHeadline.
  ///
  /// In es, this message translates to:
  /// **'Buenas, de nuevo.'**
  String get loginHeadline;

  /// No description provided for @loginSubline.
  ///
  /// In es, this message translates to:
  /// **'Retoma tus tareas donde las dejaste.'**
  String get loginSubline;

  /// No description provided for @loginForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginSubmit;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In es, this message translates to:
  /// **'o continúa con'**
  String get loginOrContinueWith;

  /// No description provided for @loginNewToFlowly.
  ///
  /// In es, this message translates to:
  /// **'¿Nuevo en Flowly? '**
  String get loginNewToFlowly;

  /// No description provided for @loginCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear una cuenta'**
  String get loginCreateAccount;

  /// No description provided for @registerHeadline.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta.'**
  String get registerHeadline;

  /// No description provided for @registerSubline.
  ///
  /// In es, this message translates to:
  /// **'Empieza a crear hábitos que perduran.'**
  String get registerSubline;

  /// No description provided for @registerSubmit.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerSubmit;

  /// No description provided for @registerWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Flowly, {name} 🎉'**
  String registerWelcome(String name);

  /// No description provided for @fieldNameLabel.
  ///
  /// In es, this message translates to:
  /// **'NOMBRE'**
  String get fieldNameLabel;

  /// No description provided for @fieldNamePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre completo'**
  String get fieldNamePlaceholder;

  /// No description provided for @fieldEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'EMAIL'**
  String get fieldEmailLabel;

  /// No description provided for @fieldEmailPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'tu@flowly.com'**
  String get fieldEmailPlaceholder;

  /// No description provided for @fieldEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un email válido.'**
  String get fieldEmailInvalid;

  /// No description provided for @fieldPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'CONTRASEÑA'**
  String get fieldPasswordLabel;

  /// No description provided for @fieldPasswordPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'8+ caracteres'**
  String get fieldPasswordPlaceholder;

  /// No description provided for @fieldPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria.'**
  String get fieldPasswordRequired;

  /// No description provided for @fieldPasswordMinLength.
  ///
  /// In es, this message translates to:
  /// **'Usa al menos 8 caracteres.'**
  String get fieldPasswordMinLength;

  /// No description provided for @fieldConfirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'CONFIRMAR CONTRASEÑA'**
  String get fieldConfirmPasswordLabel;

  /// No description provided for @fieldConfirmPasswordPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get fieldConfirmPasswordPlaceholder;

  /// No description provided for @fieldPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get fieldPasswordMismatch;

  /// No description provided for @socialGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get socialGoogle;

  /// No description provided for @socialApple.
  ///
  /// In es, this message translates to:
  /// **'Apple'**
  String get socialApple;

  /// No description provided for @dailyTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas diarias'**
  String get dailyTasksTitle;

  /// No description provided for @dailyTasksNewColumn.
  ///
  /// In es, this message translates to:
  /// **'Nueva columna'**
  String get dailyTasksNewColumn;

  /// No description provided for @dailyTasksAddColumn.
  ///
  /// In es, this message translates to:
  /// **'Añadir columna'**
  String get dailyTasksAddColumn;

  /// No description provided for @dailyTasksAddTask.
  ///
  /// In es, this message translates to:
  /// **'+ Añadir tarea'**
  String get dailyTasksAddTask;

  /// No description provided for @dailyTasksEmptyColumn.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas todavía'**
  String get dailyTasksEmptyColumn;

  /// No description provided for @dailyTasksViewByStatus.
  ///
  /// In es, this message translates to:
  /// **'Por estado'**
  String get dailyTasksViewByStatus;

  /// No description provided for @dailyTasksViewAll.
  ///
  /// In es, this message translates to:
  /// **'Todas las tareas'**
  String get dailyTasksViewAll;

  /// No description provided for @scheduleTitle.
  ///
  /// In es, this message translates to:
  /// **'Plan de hoy'**
  String get scheduleTitle;

  /// No description provided for @scheduleViewDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get scheduleViewDay;

  /// No description provided for @scheduleViewWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get scheduleViewWeek;

  /// No description provided for @scheduleCreateEventTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get scheduleCreateEventTitle;

  /// No description provided for @scheduleEventNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Tarea'**
  String get scheduleEventNameLabel;

  /// No description provided for @scheduleEventNamePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Qué vas a hacer en esta franja'**
  String get scheduleEventNamePlaceholder;

  /// No description provided for @scheduleStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get scheduleStartLabel;

  /// No description provided for @scheduleEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get scheduleEndLabel;

  /// No description provided for @scheduleInvalidRange.
  ///
  /// In es, this message translates to:
  /// **'La hora de fin debe ser posterior al inicio.'**
  String get scheduleInvalidRange;

  /// No description provided for @columnRename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get columnRename;

  /// No description provided for @columnDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get columnDelete;

  /// No description provided for @taskEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get taskEdit;

  /// No description provided for @taskDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get taskDelete;

  /// No description provided for @dialogCreateColumnTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva columna'**
  String get dialogCreateColumnTitle;

  /// No description provided for @dialogRenameColumnTitle.
  ///
  /// In es, this message translates to:
  /// **'Renombrar columna'**
  String get dialogRenameColumnTitle;

  /// No description provided for @dialogCreateTaskTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get dialogCreateTaskTitle;

  /// No description provided for @dialogNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get dialogNameLabel;

  /// No description provided for @dialogNamePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la columna'**
  String get dialogNamePlaceholder;

  /// No description provided for @dialogTaskPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Describe la tarea'**
  String get dialogTaskPlaceholder;

  /// No description provided for @dialogConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get dialogConfirm;

  /// No description provided for @dialogCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get dialogCancel;

  /// No description provided for @dialogDeleteColumnTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar columna'**
  String get dialogDeleteColumnTitle;

  /// No description provided for @dialogDeleteColumnBody.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará la columna «{column}» y sus {count} tareas. Esta acción no se puede deshacer.'**
  String dialogDeleteColumnBody(String column, int count);

  /// No description provided for @dialogEditTaskTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar tarea'**
  String get dialogEditTaskTitle;

  /// No description provided for @dialogDeleteTaskTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get dialogDeleteTaskTitle;

  /// No description provided for @dialogDeleteTaskBody.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará la tarea «{task}». Esta acción no se puede deshacer.'**
  String dialogDeleteTaskBody(String task);

  /// No description provided for @dialogTaskColumnLabel.
  ///
  /// In es, this message translates to:
  /// **'Columna'**
  String get dialogTaskColumnLabel;

  /// No description provided for @dialogTaskNoColumns.
  ///
  /// In es, this message translates to:
  /// **'Añade una columna antes de crear tareas.'**
  String get dialogTaskNoColumns;

  /// No description provided for @navTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get navTasks;

  /// No description provided for @navHabits.
  ///
  /// In es, this message translates to:
  /// **'Hábitos'**
  String get navHabits;

  /// No description provided for @navSchedule.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get navSchedule;

  /// No description provided for @navFocus.
  ///
  /// In es, this message translates to:
  /// **'Timer'**
  String get navFocus;

  /// No description provided for @navBlackList.
  ///
  /// In es, this message translates to:
  /// **'Lista negra'**
  String get navBlackList;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @blackListTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista negra'**
  String get blackListTitle;

  /// No description provided for @blackListHint.
  ///
  /// In es, this message translates to:
  /// **'Empieza a escribir…'**
  String get blackListHint;

  /// No description provided for @comingSoonTitle.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In es, this message translates to:
  /// **'Esta pantalla todavía no está disponible.'**
  String get comingSoonBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
