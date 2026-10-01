import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/text_styles.dart';
import '../../data/black_list_repository.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla «Black List»: escritura libre a modo de listado (mockup 06).
///
/// Sirve para apuntar pequeñas cosas a modo de recordatorio. Funciona como un
/// único campo de texto: cada línea es un apunte, no hay botones externos y el
/// texto se autoguarda en local con cada cambio (sin migración a API/BD, ver
/// [LocalBlackListRepository]).
class BlackListScreen extends StatefulWidget {
  const BlackListScreen({super.key, required this.ownerId});

  /// Email del perfil con el que se asocia la persistencia local.
  final String ownerId;

  @override
  State<BlackListScreen> createState() => _BlackListScreenState();
}

class _BlackListScreenState extends State<BlackListScreen> {
  final BlackListRepository _repository = LocalBlackListRepository();
  final TextEditingController _controller = TextEditingController();

  /// Retardo del autoguardado: evita escribir en cada tecla.
  Timer? _saveTimer;

  /// `false` mientras se carga el texto guardado del usuario.
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Guardado final por si quedó un cambio pendiente del debounce.
    _repository.save(widget.ownerId, _controller.text);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final text = await _repository.load(widget.ownerId);
    if (!mounted) return;
    _controller.text = text ?? '';
    setState(() => _loaded = true);
  }

  void _scheduleSave(String text) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), () {
      _repository.save(widget.ownerId, text);
    });
  }

  /// Fecha del día localizada («lunes, 28 septiembre») con mayúscula inicial.
  String _formattedDate(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat('EEEE, d MMMM', locale).format(DateTime.now());
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              // Mismo margen superior y lateral que Daily Tasks y Agenda para
              // alinear la cabecera con el resto de pantallas.
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formattedDate(context), style: AppTextStyles.eyebrow),
                  const SizedBox(height: 3),
                  Text(l10n.blackListTitle, style: AppTextStyles.screenTitle),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _loaded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: TextField(
                        key: const Key('black-list-editor'),
                        controller: _controller,
                        onChanged: _scheduleSave,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: AppTextStyles.writingText,
                        // Sin autocorrección ni sugerencias: cada línea es un
                        // apunte libre (nombres, siglas), no una frase.
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          hintText: l10n.blackListHint,
                          hintStyle: AppTextStyles.writingHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}