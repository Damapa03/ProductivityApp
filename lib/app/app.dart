import 'package:flutter/material.dart';

import '../features/login/login_screen.dart';
import '../l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// Raíz de la aplicación Flowly.
class FlowlyApp extends StatefulWidget {
  const FlowlyApp({super.key});

  @override
  State<FlowlyApp> createState() => _FlowlyAppState();
}

class _FlowlyAppState extends State<FlowlyApp> {
  @override
  void initState() {
    super.initState();
    // Recupera la preferencia de tema guardada, si la hay.
    ThemeController.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Flowly',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          // Español por defecto; el mecanismo permite conmutar a «en» (sin
          // control visual todavía).
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        );
      },
    );
  }
}
