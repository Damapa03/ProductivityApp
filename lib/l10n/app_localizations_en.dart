// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Flowly';

  @override
  String get loginHeadline => 'Good to see you again.';

  @override
  String get loginSubline => 'Pick up your tasks where you left off.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginOrContinueWith => 'or continue with';

  @override
  String get loginNewToFlowly => 'New to Flowly? ';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get registerHeadline => 'Create your account.';

  @override
  String get registerSubline => 'Start building habits that stick.';

  @override
  String get registerSubmit => 'Create account';

  @override
  String registerWelcome(String name) {
    return 'Welcome to Flowly, $name 🎉';
  }

  @override
  String get fieldNameLabel => 'NAME';

  @override
  String get fieldNamePlaceholder => 'Your full name';

  @override
  String get fieldEmailLabel => 'EMAIL';

  @override
  String get fieldEmailPlaceholder => 'you@flowly.com';

  @override
  String get fieldEmailInvalid => 'Enter a valid email address.';

  @override
  String get fieldPasswordLabel => 'PASSWORD';

  @override
  String get fieldPasswordPlaceholder => '8+ characters';

  @override
  String get fieldPasswordRequired => 'Password is required.';

  @override
  String get fieldPasswordMinLength => 'Use at least 8 characters.';

  @override
  String get fieldConfirmPasswordLabel => 'CONFIRM PASSWORD';

  @override
  String get fieldConfirmPasswordPlaceholder => 'Repeat your password';

  @override
  String get fieldPasswordMismatch => 'Passwords do not match.';

  @override
  String get socialGoogle => 'Google';

  @override
  String get socialApple => 'Apple';

  @override
  String get dailyTasksTitle => 'Daily tasks';

  @override
  String get dailyTasksNewColumn => 'New column';

  @override
  String get dailyTasksAddColumn => 'Add column';

  @override
  String get dailyTasksAddTask => '+ Add task';

  @override
  String get dailyTasksEmptyColumn => 'No tasks yet';

  @override
  String get dailyTasksViewByStatus => 'By status';

  @override
  String get dailyTasksViewAll => 'All tasks';

  @override
  String get scheduleTitle => 'Today\'s plan';

  @override
  String get scheduleWeekTitle => 'This week';

  @override
  String get scheduleViewDay => 'Day';

  @override
  String get scheduleViewWeek => 'Week';

  @override
  String get scheduleCreateEventTitle => 'New task';

  @override
  String get scheduleEventNameLabel => 'Task';

  @override
  String get scheduleEventNamePlaceholder =>
      'What will you do in this time slot';

  @override
  String get scheduleStartLabel => 'Start';

  @override
  String get scheduleEndLabel => 'End';

  @override
  String get scheduleDayLabel => 'Day';

  @override
  String get scheduleInvalidRange => 'End time must be later than start.';

  @override
  String get columnRename => 'Rename';

  @override
  String get columnDelete => 'Delete';

  @override
  String get taskEdit => 'Edit';

  @override
  String get taskDelete => 'Delete';

  @override
  String get dialogCreateColumnTitle => 'New column';

  @override
  String get dialogRenameColumnTitle => 'Rename column';

  @override
  String get dialogCreateTaskTitle => 'New task';

  @override
  String get dialogNameLabel => 'Name';

  @override
  String get dialogNamePlaceholder => 'Column name';

  @override
  String get dialogTaskPlaceholder => 'Describe the task';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogDeleteColumnTitle => 'Delete column';

  @override
  String dialogDeleteColumnBody(String column, int count) {
    return 'Column \"$column\" and its $count tasks will be deleted. This cannot be undone.';
  }

  @override
  String get dialogEditTaskTitle => 'Edit task';

  @override
  String get dialogDeleteTaskTitle => 'Delete task';

  @override
  String dialogDeleteTaskBody(String task) {
    return 'Task \"$task\" will be deleted. This cannot be undone.';
  }

  @override
  String get dialogTaskColumnLabel => 'Column';

  @override
  String get dialogTaskNoColumns => 'Add a column before creating tasks.';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navHabits => 'Habits';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navFocus => 'Timer';

  @override
  String get navBlackList => 'Black List';

  @override
  String get navProfile => 'Profile';

  @override
  String get blackListTitle => 'Black List';

  @override
  String get blackListHint => 'Start typing…';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This screen is not available yet.';
}
