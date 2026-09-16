import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/social_button.dart';
import '../../widgets/underline_field.dart';

/// Pantalla de acceso (Login) de Flowly.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
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
                const UnderlineField(
                  label: 'EMAIL',
                  placeholder: 'you@flowly.com',
                  initiallyFocused: true,
                ),
                const SizedBox(height: 32),
                const UnderlineField(
                  label: 'PASSWORD',
                  placeholder: 'Enter your password',
                  obscureText: true,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {},
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
