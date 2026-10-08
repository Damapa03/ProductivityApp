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
  String get scheduleToday => 'Today';

  @override
  String get schedulePreviousDay => 'Previous day';

  @override
  String get scheduleNextDay => 'Next day';

  @override
  String get schedulePreviousWeek => 'Previous week';

  @override
  String get scheduleNextWeek => 'Next week';

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
  String get habitsTitle => 'Habits';

  @override
  String get habitsToday => 'Today';

  @override
  String habitsProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get habitsAddHabit => '+ Add habit';

  @override
  String get habitsAddHabitTitle => 'New habit';

  @override
  String get habitsAddHabitLabel => 'HABIT';

  @override
  String get habitsAddHabitPlaceholder => 'Drink 2 L of water';

  @override
  String get habitsAdd => 'Add';

  @override
  String get habitsEmpty => 'No habits yet. Add the first one.';

  @override
  String get habitsDelete => 'Delete';

  @override
  String get habitsDeleteTitle => 'Delete habit';

  @override
  String habitsDeleteBody(String habit) {
    return 'Habit \"$habit\" and its marked days will be deleted. This cannot be undone.';
  }

  @override
  String get habitsPreviousMonth => 'Previous month';

  @override
  String get habitsNextMonth => 'Next month';

  @override
  String get habitsLegendDone => 'All habits done';

  @override
  String get habitsLegendMissed => 'Missed one or more';

  @override
  String habitsDayStatus(int day, String month, String status) {
    return '$day of $month: $status';
  }

  @override
  String get habitsStatusDone => 'all habits done';

  @override
  String get habitsStatusMissed => 'one or more habits pending';

  @override
  String get habitsStatusNeutral => 'not closed yet';

  @override
  String get habitsStatusFuture => 'upcoming day';

  @override
  String habitsToggleSemantics(String habit, String date) {
    return '$habit, for $date';
  }

  @override
  String get blackListTitle => 'Black List';

  @override
  String get blackListHint => 'Start typing…';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This screen is not available yet.';

  @override
  String get timerTitle => 'Timer';

  @override
  String get timerMode => 'Mode';

  @override
  String get timerModeWork => 'Work';

  @override
  String get timerModeStudy => 'Study';

  @override
  String get timerTimes => 'Times';

  @override
  String get timerPhaseWork => 'Work';

  @override
  String get timerPhaseBreak => 'Break';

  @override
  String get timerPhaseReview => 'Review';

  @override
  String get timerStart => 'Start';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerReset => 'Reset';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGroupAccount => 'Account';

  @override
  String get profileGroupPreferences => 'Preferences';

  @override
  String get profileGroupSupport => 'Support';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileConnectedCalendars => 'Connected calendars';

  @override
  String get profileConnectedValue => '2 linked';

  @override
  String get profileDailyReminders => 'Daily reminders';

  @override
  String get profileDarkMode => 'Dark mode';

  @override
  String get profileWeekStartsOn => 'Week starts on';

  @override
  String get profileWeekMonday => 'Monday';

  @override
  String get profileHelpCentre => 'Help centre';

  @override
  String get profileLogout => 'Log out';
}
