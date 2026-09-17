import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../data/profile_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/social_button.dart';
import '../../widgets/underline_field.dart';
import '../daily_tasks/daily_tasks_screen.dart';
import '../register/register_screen.dart';

/// Pantalla de acceso (Login) de Flowly.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final typedEmail = _emailController.text.trim().toLowerCase();
    // Demo sin API: se abre el tablero asociado al perfil guardado (email)
    // o, en su defecto, al email escrito.
    final profile = await LocalProfileRepository().load();
    if (!mounted) return;
    final ownerId =
        (profile != null && profile.email.isNotEmpty) ? profile.email : typedEmail;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DailyTasksScreen(ownerId: ownerId),
      ),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(),
                  const SizedBox(height: 52),
                  Text(
                    l10n.loginHeadline,
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.loginSubline,
                    style: AppTextStyles.subline,
                  ),
                  const SizedBox(height: 42),
                  UnderlineField(
                    label: l10n.fieldEmailLabel,
                    placeholder: l10n.fieldEmailPlaceholder,
                    initiallyFocused: true,
                    controller: _emailController,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? l10n.fieldEmailInvalid
                        : null,
                  ),
                  const SizedBox(height: 28),
                  UnderlineField(
                    label: l10n.fieldPasswordLabel,
                    placeholder: l10n.fieldPasswordPlaceholder,
                    obscureText: true,
                    controller: _passwordController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.fieldPasswordRequired
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.loginForgotPassword,
                        style: AppTextStyles.fieldLabel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _logIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: Text(l10n.loginSubmit),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          l10n.loginOrContinueWith,
                          style: AppTextStyles.eyebrow,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      SocialButton(icon: Icons.g_mobiledata, label: l10n.socialGoogle),
                      const SizedBox(width: 12),
                      SocialButton(icon: Icons.apple, label: l10n.socialApple),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: TextButton(
                      onPressed: _openRegister,
                      child: Text.rich(
                        TextSpan(
                          text: l10n.loginNewToFlowly,
                          style: AppTextStyles.eyebrow,
                          children: [
                            TextSpan(
                              text: l10n.loginCreateAccount,
                              style: AppTextStyles.link,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
