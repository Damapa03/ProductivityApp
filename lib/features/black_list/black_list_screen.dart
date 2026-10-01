import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/text_styles.dart';
import '../../data/black_list_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/screen_header.dart';

/// Pantalla «Black List»: escritura libre a modo de listado (mockup 06).
///
/// Sirve para apuntar pequeñas cosas a modo de recordatorio. Funciona como un
/// único campo de texto: cada línea es un apunte con su viñeta «•» visible, no
/// hay botones externos y el texto se autoguarda en local con cada cambio (sin
/// migración a API/BD, ver [LocalBlackListRepository]). Las viñetas son solo
/// visuales: en local se guarda el texto plano, sin los símbolos «•».
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

  /// Prefijo de viñeta que se antepone a cada línea con contenido.
  static const String _bullet = '• ';

  /// Símbolo de viñeta, sin el espacio que la sigue.
  static const String _bulletMark = '•';

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
    _repository.save(widget.ownerId, _stripBullets(_controller.text));
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final text = await _repository.load(widget.ownerId);
    if (!mounted) return;
    _controller.text = text ?? '';
    // Al restaurar el texto plano hay que volver a pintar las viñetas.
    _syncBullets();
    setState(() => _loaded = true);
  }

  /// Quita la viñeta inicial de una línea (como mucho una) y el espacio que la
  /// sigue, para trabajar siempre con el contenido puro.
  ///
  /// Acepta también una viñeta suelta sin espacio: si no, al borrar el espacio
  /// de una línea vacía la viñeta reaparecía y el texto se llenaba de «• •».
  String _stripBullet(String line) {
    var content = line.startsWith(_bulletMark) ? line.substring(1) : line;
    if (content.startsWith(' ')) content = content.substring(1);
    return content;
  }

  /// Texto sin viñetas: lo que se guarda en local (texto plano por línea).
  String _stripBullets(String text) =>
      text.split('\n').map(_stripBullet).join('\n');

  /// Garantiza que cada línea **con contenido** empiece por su viñeta «• ».
  ///
  /// Las líneas vacías se dejan sin viñeta a propósito: así la línea recién
  /// creada (o la que se vacía) se borra de una tecla, sin que reaparezca la
  /// viñeta. El cursor se mantiene en la línea en la que se escribe. El texto
  /// vacío no se toca (ahí se muestra la pista).
  void _syncBullets() {
    final value = _controller.value;
    final text = value.text;
    if (text.isEmpty) return;
    final caret = value.selection.isValid && value.selection.isCollapsed
        ? value.selection.baseOffset
        : text.length;

    final parts = text.split('\n');
    final lines = <_Line>[];
    final buffer = StringBuffer();
    var originalStart = 0;
    for (var i = 0; i < parts.length; i++) {
      final content = _stripBullet(parts[i]);
      final bulleted = content.isNotEmpty;
      final rebuilt = bulleted ? '$_bullet$content' : content;
      lines.add(_Line(
        originalStart: originalStart,
        originalLength: parts[i].length,
        newStart: buffer.length,
        newLength: rebuilt.length,
        bulleted: bulleted,
      ));
      buffer.write(rebuilt);
      originalStart += parts[i].length + 1; // +1: el salto de línea
      if (i < parts.length - 1) buffer.write('\n');
    }

    final joined = buffer.toString();
    if (joined == text) return;
    _controller.value = TextEditingValue(
      text: joined,
      selection: TextSelection.collapsed(
        offset: _caretIn(joined.length, caret, lines),
      ),
    );
  }

  /// Dónde queda el cursor en el texto reconstruido.
  ///
  /// El cursor se desplaza con el contenido de su línea: si a esa línea se le
  /// añade la viñeta, avanza [_bullet.length] caracteres; si se le quita,
  /// retrocede lo mismo.
  int _caretIn(int textLength, int caret, List<_Line> lines) {
    for (final line in lines) {
      if (caret > line.originalStart + line.originalLength) continue;
      final inside = caret - line.originalStart;
      final shift = line.newLength - line.originalLength;
      final offset = line.newStart + inside + shift;
      // Dentro de los límites de su línea.
      final lower = line.newStart;
      final upper = line.newStart + line.newLength;
      if (offset < lower) return lower;
      if (offset > upper) return upper;
      return offset;
    }
    return textLength;
  }

  void _handleChanged(String _) {
    _syncBullets();
    _scheduleSave(_stripBullets(_controller.text));
  }

  void _scheduleSave(String text) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), () {
      _repository.save(widget.ownerId, text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera compartida con el resto de pantallas (fecha + nombre).
            ScreenHeader(title: l10n.blackListTitle),
            Expanded(
              child: _loaded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: TextField(
                        key: const Key('black-list-editor'),
                        controller: _controller,
                        onChanged: _handleChanged,
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
                          // El tema global rellena los campos con `cardBg`; aquí
                          // el papel de la pantalla debe verse igual con o sin
                          // foco, así que el campo no pinta fondo propio.
                          filled: false,
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

/// Una línea del apunte durante la reconstrucción de las viñetas.
///
/// Guarda dónde empieza y cuánto mide en el texto original y en el nuevo, para
/// poder llevar el cursor a su sitio tras rebuildar la línea (ver `_caretIn`).
class _Line {
  const _Line({
    required this.originalStart,
    required this.originalLength,
    required this.newStart,
    required this.newLength,
    required this.bulleted,
  });

  final int originalStart;
  final int originalLength;
  final int newStart;
  final int newLength;

  /// Si la línea lleva viñeta en el texto reconstruido.
  final bool bulleted;
}