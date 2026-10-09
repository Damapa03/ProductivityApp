import 'package:flutter/material.dart';

import '../../app/theme/palette.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/time_blocks_icon.dart';
import '../black_list/black_list_screen.dart';
import '../daily_schedule/daily_schedule_screen.dart';
import '../daily_tasks/daily_tasks_screen.dart';
import '../habit_calendar/habit_calendar_screen.dart';
import '../profile/profile_screen.dart';
import '../timer/timer_screen.dart';

/// Contenedor raíz tras el acceso: aloja las pantallas y la navegación
/// inferior (ver mockup 07).
///
/// Las seis pestañas tienen pantalla propia. `ComingSoonScreen` sigue en el
/// proyecto por si alguna vuelve a quedar pendiente.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.ownerId});

  /// Email del perfil con el que se asocia la persistencia del tablero.
  final String ownerId;

  /// Índice de la pestaña Agenda en la navegación inferior.
  static const int scheduleTabIndex = 2;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  /// Pestaña activa; por defecto «Tareas».
  int _index = 0;

  /// Marca de entradas a la pestaña Agenda: cambia cada vez que se selecciona
  /// para que la línea de tiempo vuelva a enfocar la hora actual sin
  /// reconstruir el estado de la pantalla (ver `entryTick` de la pantalla).
  int _scheduleEntryTick = 0;

  void _select(int index) {
    // Tocar la pestaña ya activa es un no-op.
    if (index == _index) return;
    // Cada entrada a Agenda incrementa la marca de reenfoque del scroll.
    if (index == HomeShell.scheduleTabIndex) _scheduleEntryTick++;
    setState(() => _index = index);
  }

  /// Las pestañas se construyen en cada `build` porque sus etiquetas vienen
  /// de l10n.
  List<_NavTab> _tabs(AppLocalizations l10n) {
    return [
      _NavTab(
        label: l10n.navTasks,
        icon: const Icon(Icons.view_list_outlined),
        screen: (_) => DailyTasksScreen(ownerId: widget.ownerId),
      ),
      _NavTab(
        label: l10n.navHabits,
        icon: const Icon(Icons.calendar_month_outlined),
        screen: (context) => HabitCalendarScreen(ownerId: widget.ownerId),
      ),
      _NavTab(
        label: l10n.navSchedule,
        icon: const TimeBlocksIcon(),
        // `entryTick` reenfoca la línea de tiempo en la hora actual en cada
        // entrada a la pestaña Agenda.
        screen: (context) => DailyScheduleScreen(
          ownerId: widget.ownerId,
          entryTick: _scheduleEntryTick,
        ),
      ),
      _NavTab(
        label: l10n.navFocus,
        icon: const Icon(Icons.schedule_outlined),
        screen: (context) => const TimerScreen(),
      ),
      _NavTab(
        label: l10n.navBlackList,
        icon: const Icon(Icons.description_outlined),
        screen: (context) => BlackListScreen(ownerId: widget.ownerId),
      ),
      _NavTab(
        label: l10n.navProfile,
        icon: const Icon(Icons.person_outline),
        screen: (context) => ProfileScreen(ownerId: widget.ownerId),
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
    final palette = Palette.of(context);
    return Container(
      key: const Key('bottom-nav'),
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: _hPadding),
      decoration: BoxDecoration(
        color: palette.paper,
        border: Border(top: BorderSide(color: palette.line)),
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
    final palette = Palette.of(context);
    final color = active ? palette.pineDeep : palette.navInactive;

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
              color: active ? palette.pinePale : Colors.transparent,
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
