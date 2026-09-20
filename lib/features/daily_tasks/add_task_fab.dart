import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../l10n/app_localizations.dart';

/// Botón flotante para añadir una tarea pidiendo nombre y columna destino.
///
/// Está presente tanto en la vista «Por estado» como en «Todas las tareas».
class AddTaskFab extends StatelessWidget {
  const AddTaskFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.pineDeep,
      foregroundColor: const Color(0xFFF3F4EF),
      tooltip: l10n.dailyTasksAddTask,
      child: const Icon(Icons.add),
    );
  }
}