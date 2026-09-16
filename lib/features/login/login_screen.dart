import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/social_button.dart';
import '../../widgets/underline_field.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome back. (demo, sin API)')),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Good to see you again.',
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pick up your tasks where you left off.',
                    style: AppTextStyles.subline,
                  ),
                  const SizedBox(height: 42),
                  UnderlineField(
                    label: 'EMAIL',
                    placeholder: 'you@flowly.com',
                    initiallyFocused: true,
                    controller: _emailController,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email address.'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  UnderlineField(
                    label: 'PASSWORD',
                    placeholder: 'Enter your password',
                    obscureText: true,
                    controller: _passwordController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Password is required.'
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot password?',
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
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: AppTextStyles.eyebrow,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    children: [
                      SocialButton(icon: Icons.g_mobiledata, label: 'Google'),
                      SizedBox(width: 12),
                      SocialButton(icon: Icons.apple, label: 'Apple'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: TextButton(
                      onPressed: _openRegister,
                      child: Text.rich(
                        TextSpan(
                          text: 'New to Flowly? ',
                          style: AppTextStyles.eyebrow,
                          children: [
                            TextSpan(
                              text: 'Create an account',
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
