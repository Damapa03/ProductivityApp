import 'package:flutter/material.dart';

import '../app/theme/colors.dart';
import '../app/theme/text_styles.dart';

/// Campo con subrayado (estilo Flowly).
class UnderlineField extends StatelessWidget {
  const UnderlineField({
    super.key,
    required this.label,
    this.placeholder,
    this.obscureText = false,
    this.initiallyFocused = false,
    this.onSubmitted,
    this.textInputAction,
  });

  final String label;
  final String? placeholder;
  final bool obscureText;
  final bool initiallyFocused;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 10),
        TextField(
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          autofocus: initiallyFocused,
          style: AppTextStyles.fieldInput,
          decoration: InputDecoration(
            isDense: true,
            hintText: placeholder,
            hintStyle: AppTextStyles.fieldPlaceholder,
          ),
          cursorColor: AppColors.pine,
        ),
        const SizedBox(height: 8),
        Container(height: 1.5, color: AppColors.lineFaint),
      ],
    );
  }
}
