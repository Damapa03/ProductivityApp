# Flowly — Productividad y buenos hábitos

> Aplicación multiplataforma (Android, iOS, Web, Windows, macOS, Linux) para
> fomentar la productividad, los buenos hábitos y el deep-work. Flutter +
> Material 3.

## Estado del proyecto

**En curso, con las pantallas del mockup ya implementadas.** La app reúne:

- Las pantallas de producto —login, registro, tareas diarias, calendario de
  hábitos, agenda, temporizador, lista negra y perfil— dentro de un *shell* con
  navegación inferior.
- **Tema claro y oscuro** con conmutador persistido.
- **Internacionalización** español/inglés (español por defecto).
- **Persistencia local** mediante repositorios desacoplados, preparada para
  migrar a una API externa.
- Token de diseño en `flowly-design-tokens.json` (con bloque oscuro) y la
  tipografía **Space Grotesk** / **IBM Plex Sans** embebida.

Los mockups HTML viven en `/mockups` como **referencia local**: ya no se
versionan.

## Funcionalidades

- **Login y registro**: campos con subrayado, botones sociales (Google/Apple) y
  wordmark de marca.
- **Tareas diarias**: vista *kanban* y vista de lista, con crear, editar y
  eliminar tareas y columnas, y mover tareas entre columnas.
- **Calendario de hábitos**: rejilla mensual, lista chequeable del día y
  registro diario de cada hábito.
- **Agenda**: vista diaria («Plan de hoy») y semanal («Esta semana»), franjas
  con colores cíclicos y diálogos de creación y edición.
- **Temporizador Pomodoro**: modos trabajo y estudio, secuencia de fases y anillo
  circular de progreso.
- **Lista negra**.
- **Perfil**: identidad, ajustes agrupados y el interruptor de *Modo oscuro*.
- **Shell de navegación** (`HomeShell`) que integra las pestañas.

## Arquitectura

```
lib/
├── app/
│   ├── app.dart              # MaterialApp + themeMode
│   └── theme/                # colors, palette, text_styles, app_theme, theme_controller
├── data/                     # repositorios (profile, habits, kanban, schedule, black_list)
├── features/
│   ├── login/                # LoginScreen
│   ├── register/             # RegisterScreen
│   ├── home/                 # HomeShell + ComingSoonScreen
│   ├── daily_tasks/          # kanban + lista, tarjetas y diálogos
│   ├── habit_calendar/       # rejilla mensual + lista chequeable
│   ├── daily_schedule/       # vistas diaria y semanal + pintado
│   ├── timer/                # controller, models y widgets
│   ├── black_list/           # BlackListScreen
│   └── profile/              # ProfileScreen
├── models/                   # Profile, Habit, Kanban*, DailySchedule, ScheduleEvent
├── widgets/                  # brand_mark, screen_header, social_button, underline_field…
├── l10n/                     # app_es.arb / app_en.arb
└── main.dart                 # entrada de la app
```

La UI depende siempre de la interfaz de repositorio, nunca de la
implementación concreta (ver `lib/data/profile_repository.dart`).

## Tema y diseño

- **Tokens**: `flowly-design-tokens.json` define los colores claros y el bloque
  `dark`; `lib/app/theme/colors.dart` los expone como `AppColors` y
  `AppColorsDark`.
- **Paleta activa**: `Palette` (`ThemeExtension`) con `Palette.light`,
  `Palette.dark` y `Palette.of(context)`. Los widgets resuelven los tokens con
  la paleta del tema en curso.
- **Tipografía**: `AppTextStyles.of(context)` devuelve la escala resuelta contra
  la paleta activa.
- **Temas**: `AppTheme.light` y `AppTheme.dark` comparten el mismo armazón y
  solo cambian la paleta y la `Brightness`.
- **Modo oscuro**: `ThemeController` (clave `flowly.theme.v1`) guarda la
  preferencia; arranca en claro y **no** usa `ThemeMode.system`. El interruptor
  del perfil lo cambia y lo persiste.

## Persistencia

Cada agregado expone un repositorio como `abstract interface class` con una
implementación `Local*` sobre `shared_preferences`, de forma que la UI no
dependa del almacenamiento. Claves:

| Clave | Contenido |
| --- | --- |
| `flowly.profile.v1` | identidad del perfil (sin contraseña) |
| `flowly.theme.v1` | preferencia de tema (claro/oscuro) |
| `flowly.kanban.v1.*` | tablero kanban por usuario |
| `flowly.habits.v1.*` | hábitos y su registro diario |
| `flowly.schedule.v1.*` | franjas de la agenda |
| `flowly.blacklist.v1.*` | lista negra |

El contrato de datos (modelos + JSON) se mantendrá estable al migrar a la API
externa. **Nunca se guardan contraseñas.**

## Internacionalización

Los textos viven en `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` y se generan
con `flutter gen-l10n`. El **español es el idioma por defecto**; el mecanismo
permite conmutar a inglés aunque todavía no haya control visual.

## Desarrollo

```bash
flutter pub get     # descargar dependencias y fuentes
flutter run         # lanzar en el dispositivo / emulador activo
flutter analyze     # verificación estática
flutter test        # tests
```

## Pruebas

`flutter test` cubre las pantallas, los datos y el tema:

- **Pantallas y widgets**: login, tareas diarias, calendario de hábitos, agenda
  (diaria y semanal), shell de navegación, perfil, cabecera y lista negra.
- **Datos y modelos**: repositorios de perfil, hábitos, kanban, agenda y lista
  negra, además de sus modelos y registros diarios.
- **Tema**: `theme_controller_test` y `palette_test` (paleta clara/oscura,
  resolución por contexto y persistencia del modo oscuro).
