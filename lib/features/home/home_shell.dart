import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/time_blocks_icon.dart';
import '../daily_schedule/daily_schedule_screen.dart';
import '../daily_tasks/daily_tasks_screen.dart';
import 'coming_soon_screen.dart';

/// Contenedor raíz tras el acceso: aloja las pantallas y la navegación
/// inferior (ver mockup 07).
///
/// «Tareas» y «Agenda» tienen pantalla propia; el resto de pestañas muestran
/// un marcador de posición hasta que tengan pantalla propia.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.ownerId});

  /// Email del perfil con el que se asocia la persistencia del tablero.
  final String ownerId;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  /// Pestaña activa; por defecto «Tareas».
  int _index = 0;

  void _select(int index) {
    // Tocar la pestaña ya activa es un no-op.
    if (index == _index) return;
    setState(() => _index = index);
  }

  /// Las pestañas se construyen en cada `build` porque sus etiquetas (y las de
  /// los marcadores) vienen de l10n.
  List<_NavTab> _tabs(AppLocalizations l10n) {
    Widget pending(String title, Widget icon) =>
        ComingSoonScreen(title: title, icon: icon);

    return [
      _NavTab(
        label: l10n.navTasks,
        icon: const Icon(Icons.view_list_outlined),
        screen: (_) => DailyTasksScreen(ownerId: widget.ownerId),
      ),
      _NavTab(
        label: l10n.navHabits,
        icon: const Icon(Icons.calendar_month_outlined),
        screen: (context) =>
            pending(l10n.navHabits, const Icon(Icons.calendar_month_outlined)),
      ),
      _NavTab(
        label: l10n.navSchedule,
        icon: const TimeBlocksIcon(),
        screen: (context) => DailyScheduleScreen(ownerId: widget.ownerId),
      ),
      _NavTab(
        label: l10n.navFocus,
        icon: const Icon(Icons.schedule_outlined),
        screen: (context) =>
            pending(l10n.navFocus, const Icon(Icons.schedule_outlined)),
      ),
      _NavTab(
        label: l10n.navBlackList,
        icon: const Icon(Icons.description_outlined),
        screen: (context) =>
            pending(l10n.navBlackList, const Icon(Icons.description_outlined)),
      ),
      _NavTab(
        label: l10n.navProfile,
        icon: const Icon(Icons.person_outline),
        screen: (context) =>
            pending(l10n.navProfile, const Icon(Icons.person_outline)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs(AppLocalizations.of(context));

    return Scaffold(
      // `IndexedStack` para que cada pestaña conserve su estado al volver.
      body: IndexedStack(
        index: _index,
        children: [for (final tab in tabs) tab.screen(context)],
      ),
      bottomNavigationBar: _BottomNav(
        tabs: tabs,
        currentIndex: _index,
        onSelected: _select,
      ),
    );
  }
}

/// Una pestaña de la navegación inferior.
class _NavTab {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.screen,
  });

  /// Nombre accesible de la pantalla (ver mockup 07).
  final String label;

  /// Icono del item; hereda el color del item activo o inactivo.
  final Widget icon;

  /// Contenido de la pestaña.
  final WidgetBuilder screen;
}

/// Barra de navegación inferior (mockup 07).
///
/// No se usa `BottomNavigationBar` para poder reproducir el mockup al pixel:
/// 64 de alto, borde superior de 1, items de 38×38 con radio 11 y reparto
/// `space-around` con 10 de margen lateral.
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<_NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Medidas del mockup.
  static const double _height = 64;
  static const double _item = 38;
  static const double _radius = 11;
  static const double _hPadding = 10;
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bottom-nav'),
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: _hPadding),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < tabs.length; i++)
            _NavItem(
              key: ValueKey('nav-item-$i'),
              tab: tabs[i],
              active: i == currentIndex,
              iconSize: _iconSize,
              size: _item,
              radius: _radius,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }
}

/// Item de la navegación inferior: cuadrado redondeado que se resalta cuando
/// su pestaña está activa.
class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.tab,
    required this.active,
    required this.size,
    required this.radius,
    required this.iconSize,
    required this.onTap,
  });

  final _NavTab tab;
  final bool active;

  /// Lado del cuadrado del item.
  final double size;
  final double radius;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.pineDeep : AppColors.navInactive;

    return Semantics(
      label: tab.label,
      selected: active,
      child: Tooltip(
        message: tab.label,
        // El nombre ya lo aporta [Semantics]; si no, se anunciaría dos veces.
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: active ? AppColors.pinePale : Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
            ),
            // El color se propaga por [IconTheme] para que todos los iconos
            // del set (incluido [TimeBlocksIcon]) se comporten igual.
            child: IconTheme(
              data: IconThemeData(color: color, size: iconSize),
              child: Center(child: tab.icon),
            ),
          ),
        ),
      ),
    );
  }
}
