import 'package:flutter/material.dart';

import '../app/theme/palette.dart';
import '../app/theme/text_styles.dart';

/// Campo de la marca Flowly: etiqueta + subrayado + placeholder.
///
/// Parámetros pensados para login y registro (UI demo, sin lógica de red).
class UnderlineField extends StatefulWidget {
  const UnderlineField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.obscureText = false,
    this.initiallyFocused = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final bool initiallyFocused;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<UnderlineField> createState() => _UnderlineFieldState();
}

class _UnderlineFieldState extends State<UnderlineField> {
  late final TextEditingController _internal;
  late final FocusNode _focus;
  bool _hasError = false     ;

  TextEditingController get _effective =>
      widget.controller ?? _internal;

  @override
  void initState() {
    super.initState();
    _internal = TextEditingController();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _internal.dispose();
    _focus.dispose();
    super.dispose();
  }

  String? _validate(String? v) => widget.validator?.call(v);

  void _handleChanged(String v) {
    if (widget.onChanged != null) widget.onChanged!(v);
  }

  void _onTapValidate() {
    final value = _effective.text;
    final error = _validate(value);
    if (error != null) {
      setState(() => _hasError = true);
    } else {
      setState(() => _hasError = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    final lineColor = _hasError ? palette.rose : palette.line;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: styles.fieldLabel),
        const SizedBox(height:       8),
        TextField(
          controller: _effective,
          focusNode: _focus,
          obscureText: widget.obscureText,
          onChanged: _handleChanged,
          onTap: _onTapValidate,
          onSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          style: styles.fieldInput,
          cursorColor: palette.pine,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.placeholder,
            hintStyle: styles.fieldPlaceholder,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 2,
          color: lineColor,
        ),
        if (widget.initiallyFocused)
          _FocusRequest(focusNode: _focus),
      ],
    );
  }
}

class _FocusRequest extends StatefulWidget {
  const _FocusRequest({required this.focusNode});
  final FocusNode focusNode;

  @override
  State<_FocusRequest> createState() => _FocusRequestState();
}

class _FocusRequestState extends State<_FocusRequest> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
