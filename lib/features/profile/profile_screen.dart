import 'package:flutter/material.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/text_styles.dart';
import '../../app/theme/theme_controller.dart';
import '../../data/profile_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/profile.dart';

/// Pantalla «Perfil» (mockup 07): identidad, ajustes agrupados y cierre de
/// sesión.
///
/// Es una pestaña del shell, así que la navegación inferior la pinta
/// [HomeShell]; la pantalla solo ocupa su cuerpo. De momento es **solo UI**:
/// las filas tienen ripple pero no abren nada, los recordatorios guardan su
/// estado únicamente en memoria y «Cerrar sesión» no cierra la sesión. La
/// excepción es «Modo oscuro», que sí cambia y persiste el tema con
/// [ThemeController].
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.ownerId});

  /// Email de la sesión: respalda la identidad cuando no hay perfil guardado.
  final String ownerId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = LocalProfileRepository();

  /// Perfil guardado; null mientras carga o si no existe.
  Profile? _profile;

  /// false mientras se carga el perfil de local.
  bool _loaded = false;

  /// Estado visual del recordatorio diario (no se persiste, ver clase).
  bool _dailyReminders = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _repository.load();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loaded = true;
    });
  }

  /// Email visible: el del perfil guardado o, en su defecto, el de sesión.
  String get _email {
    final stored = _profile?.email ?? '';
    return stored.isNotEmpty ? stored : widget.ownerId;
  }

  /// Nombre visible: el del perfil o, si no hay nombre, el propio email.
  String get _name {
    final stored = _profile?.name ?? '';
    return stored.isNotEmpty ? stored : _email;
  }

  /// Iniciales del avatar: primera letra de las dos primeras palabras del
  /// nombre («Daniel Marín» → «DM»); con una sola palabra, sus dos primeras.
  String get _initials {
    final words = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    return ('${words.first[0]}${words[1][0]}').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);

    return Scaffold(
      backgroundColor: palette.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título solo, sin la fecha del ScreenHeader: así lo muestra el
            // mockup 07.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(l10n.profileTitle, style: styles.screenTitle),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: !_loaded
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Identity(name: _name, email: _email, initials: _initials),
                          // Identidad → primer grupo: 26 del mockup + los 22
                          // de aire que lleva por delante cada etiqueta.
                          const SizedBox(height: 26),
                          _group(
                            l10n.profileGroupAccount,
                            [
                              _ProfileRow(
                                icon: Icons.person_outline,
                                label: l10n.profileEditProfile,
                                trailing: const _Chevron(),
                              ),
                              _ProfileRow(
                                icon: Icons.lock_outline,
                                label: l10n.profileChangePassword,
                                trailing: const _Chevron(),
                              ),
                              _ProfileRow(
                                icon: Icons.calendar_month_outlined,
                                label: l10n.profileConnectedCalendars,
                                trailing: Text(
                                  l10n.profileConnectedValue,
                                  style: styles.profileRowValue,
                                ),
                              ),
                            ],
                          ),
                          _group(
                            l10n.profileGroupPreferences,
                            [
                              _ProfileRow(
                                icon: Icons.wb_sunny_outlined,
                                label: l10n.profileDailyReminders,
                                interactive: false,
                                trailing: _ProfileToggle(
                                  key: const Key('profile-toggle-reminders'),
                                  value: _dailyReminders,
                                  onChanged: (value) =>
                                      setState(() => _dailyReminders = value),
                                ),
                              ),
                              _ProfileRow(
                                icon: Icons.dark_mode_outlined,
                                label: l10n.profileDarkMode,
                                interactive: false,
                                // El tema lo comparte toda la app, así que el
                                // estado vive en [ThemeController] y este
                                // interruptor solo lo refleja y lo cambia.
                                trailing: ValueListenableBuilder<ThemeMode>(
                                  valueListenable: ThemeController.instance,
                                  builder: (context, mode, _) => _ProfileToggle(
                                    key: const Key('profile-toggle-dark'),
                                    value: mode == ThemeMode.dark,
                                    onChanged: ThemeController.instance.setDark,
                                  ),
                                ),
                              ),
                              _ProfileRow(
                                icon: Icons.schedule_outlined,
                                label: l10n.profileWeekStartsOn,
                                trailing: Text(
                                  l10n.profileWeekMonday,
                                  style: styles.profileRowValue,
                                ),
                              ),
                            ],
                          ),
                          _group(
                            l10n.profileGroupSupport,
                            [
                              _ProfileRow(
                                icon: Icons.help_outline,
                                label: l10n.profileHelpCentre,
                                trailing: const _Chevron(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _ProfileLogout(label: l10n.profileLogout),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Etiqueta de grupo + su tarjeta de filas, con el aire del mockup (22 px
  /// por encima de la etiqueta y 8 hasta la tarjeta).
  Widget _group(String label, List<Widget> rows) {
    final styles = AppTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: styles.profileGroupLabel),
          const SizedBox(height: 8),
          _ProfileGroupCard(rows: rows),
        ],
      ),
    );
  }
}

/// Bloque de identidad: avatar con iniciales, nombre y email (mockup 07).
class _Identity extends StatelessWidget {
  const _Identity({
    required this.name,
    required this.email,
    required this.initials,
  });

  final String name;
  final String email;
  final String initials;

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.pinePale,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: palette.line)),
          ),
          child: Text(initials, style: styles.profileInitials),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: styles.profileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: styles.profileEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de un grupo de filas: fondo `cardBg`, borde `line` y radio 10,
/// con un separador de 1 px entre filas y sin separador en la primera.
class _ProfileGroupCard extends StatelessWidget {
  const _ProfileGroupCard({required this.rows});

  final List<Widget> rows;

  static const double radius = 10;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Material(
      color: palette.cardBg,
      borderRadius: BorderRadius.circular(radius),
      // Recorta el resalte del ripple al radio de la tarjeta.
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: palette.line),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: palette.line),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Fila de un grupo: chip de icono, etiqueta y su control a la derecha
/// (chevron, valor de texto o interruptor).
///
/// Con [interactive] la fila entera es tocable (ripple, sin acción: la
/// pantalla es solo UI). Las filas con interruptor no lo son, porque su
/// control ya es el interruptor.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.interactive = true,
  });

  final IconData icon;
  final String label;

  /// Control de la derecha.
  final Widget trailing;

  /// Si la fila responde al toque con un ripple.
  final bool interactive;

  /// Medidas del mockup 07.
  static const double chip = 30;
  static const double chipRadius = 8;
  static const double chipIcon = 16;
  static const double gap = 11;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            key: const Key('profile-row-chip'),
            width: chip,
            height: chip,
            // Centra el icono con holgura: sin esto el chip aprieta al Icon a
            // 30×30 y su caja dejan de medir los 16 px del mockup.
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.pinePale,
              borderRadius: const BorderRadius.all(Radius.circular(chipRadius)),
            ),
            child: IconTheme(
              data: IconThemeData(color: palette.pineDeep, size: chipIcon),
              child: Icon(icon),
            ),
          ),
          const SizedBox(width: gap),
          Expanded(child: Text(label, style: styles.profileRowLabel)),
          trailing,
        ],
      ),
    );

    // En las filas con interruptor, texto y control se leen como un único
    // nodo («Recordatorios diarios, activado») en lugar de dos.
    if (!interactive) return MergeSemantics(child: content);
    return InkWell(onTap: () {}, child: content);
  }
}

/// Chevron «›» a la derecha de las filas navegables (mockup 07).
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      size: 16,
      color: Palette.of(context).inkSoft,
    );
  }
}

/// Interruptor a la medida del mockup 07: 38×22 con carril de radio 12 y
/// knob de 18, en pine cuando está activo y en `line` cuando no.
///
/// No usa `Switch` (Material lo dibuja a 52×32 y con sus propios colores) ni
/// `InkWell`: el carril es opaco y taparía el splash, así que el feedback es
/// la animación del carril y la semántica de interruptor.
class _ProfileToggle extends StatelessWidget {
  const _ProfileToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Estado actual del interruptor.
  final bool value;

  /// Notifica el nuevo estado (ver [ProfileScreen]).
  final ValueChanged<bool> onChanged;

  static const double width = 38;
  static const double height = 22;
  static const double radius = 12;
  static const double knob = 18;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Semantics(
      toggled: value,
      // El nombre lo aporta la etiqueta de la fila, que se fusiona con él.
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: width,
          height: height,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: value ? palette.pine : palette.line,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Container(
            width: knob,
            height: knob,
            decoration: BoxDecoration(
              color: palette.onPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón «Cerrar sesión» a todo el ancho (mockup 07): contorno `line` y
/// texto en rose. Sin acción: la pantalla es solo UI.
class _ProfileLogout extends StatelessWidget {
  const _ProfileLogout({required this.label});

  final String label;

  static const double radius = 10;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: palette.line),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(label, style: styles.profileLogout),
        ),
      ),
    );
  }
}
