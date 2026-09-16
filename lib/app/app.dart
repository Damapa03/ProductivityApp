import 'package:flutter/material.dart';

import '../features/login/login_screen.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación Flowly.
class FlowlyApp extends StatelessWidget {
  const FlowlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowly',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
