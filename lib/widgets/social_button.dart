import 'package:flutter/material.dart';

import '../app/theme/colors.dart';
import '../app/theme/text_styles.dart';

/// Botón social (Google / Apple) de Flowly.
class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppColors.line, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: AppTextStyles.buttonSecondary,
          foregroundColor: AppColors.ink,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: AppColors.inkSoft),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
