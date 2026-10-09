import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../data/profile_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/profile.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/social_button.dart';
import '../../widgets/underline_field.dart';

/// Pantalla de Registro ("Crear cuenta") — espejo de Login + validación
/// de igualdad de contraseñas + persistencia local del perfil.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final profile = Profile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      createdAt: DateTime.now(),
    );
    await LocalProfileRepository().save(profile);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    // Registro OK → vuelve al login con un aviso.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.registerWelcome(profile.name)),
      ),
    );
    Navigator.of(context).pop();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.length < 8) {
      return AppLocalizations.of(context).fieldPasswordMinLength;
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passwordController.text) {
      return AppLocalizations.of(context).fieldPasswordMismatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final styles = AppTextStyles.of(context);
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
                    l10n.registerHeadline,
                    style: styles.headline,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.registerSubline,
                    style: styles.subline,
                  ),
                  const SizedBox(height: 42),
                  UnderlineField(
                    label: l10n.fieldNameLabel,
                    placeholder: l10n.fieldNamePlaceholder,
                    initiallyFocused: true,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 28),
                  UnderlineField(
                    label: l10n.fieldEmailLabel,
                    placeholder: l10n.fieldEmailPlaceholder,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 28),
                  FormField<String?>(
                    validator: (v) =>
                        _validatePassword(_passwordController.text),
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UnderlineField(
                          label: l10n.fieldPasswordLabel,
                          placeholder: l10n.fieldPasswordPlaceholder,
                          obscureText: true,
                          onChanged: (v) => field.didChange(v),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              field.errorText!,
                              style: styles.fieldError,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FormField<String?>(
                    validator: (v) => _validateConfirm(_confirmController.text),
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UnderlineField(
                          label: l10n.fieldConfirmPasswordLabel,
                          placeholder: l10n.fieldConfirmPasswordPlaceholder,
                          obscureText: true,
                          onChanged: (v) => field.didChange(v),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              field.errorText!,
                              style: styles.fieldError,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
                  Row(
                    children: [
                      SocialButton(
                        icon: Icons.g_mobiledata,
                        label: l10n.socialGoogle,
                      ),
                      const SizedBox(width: 12),
                      SocialButton(icon: Icons.apple, label: l10n.socialApple),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(l10n.registerSubmit),
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
