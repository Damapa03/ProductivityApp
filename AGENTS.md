# AGENTS.md

## Identidad del proyecto

**Flowly** — aplicación multiplataforma (Android, iOS, Web, Windows, macOS,
Linux) para fomentar la productividad, los buenos hábitos y el deep-work.
Stack: **Flutter + Material 3**, Dart null-safety. Diseño definido por tokens
(`flowly-design-tokens.json`).

## Comandos

```bash
flutter pub get     # descargar dependencias y fuentes
flutter run         # lanzar en el dispositivo / emulador activo
flutter analyze     # verificación estática
flutter test        # tests
```

## Arquitectura

```
lib/
├── app/
│   ├── app.dart              # MaterialApp + rutas
│   └── theme/                # tokens: colors, text_styles, app_theme
├── features/
│   ├── login/                # LoginScreen
│   └── register/             # RegisterScreen
├── data/                     # repositorios (persistencia)
├── models/                   # modelos de dominio (p. ej. Profile)
├── widgets/                  # brand_mark, social_button, underline_field
└── main.dart                 # entrada de la app
```

Los mockups de las pantallas están en `/mockups` (`01-login` … `07-profile`).

## Persistencia (convención crítica)

La persistencia es **local por ahora** (`shared_preferences`) y está pensada
para migrar después a una **API externa** que realice la persistencia definitiva.
Reglas:

1. Cada agregado expone un repositorio como `abstract interface class`
   (ver `lib/data/profile_repository.dart`) para desacoplar UI de datos.
2. La UI depende solo de la interfaz, nunca de la implementación local.
3. El contrato de datos (modelos + JSON) se mantiene estable entre ambas fases.
4. NUNCA se guardan contraseñas; el `Profile` solo tiene datos de identidad
   (demo local).

Implementación actual: `LocalProfileRepository` con clave `flowly.profile.v1`.

## Design tokens

- Tipografía: **Space Grotesk** (display / títulos) e **IBM Plex Sans** (cuerpo),
  embebidas en `assets/fonts/` y declaradas en `pubspec.yaml`. Solo existen
  pesos 400, 500, 600 y 700.
- Paleta (en `lib/app/theme/colors.dart`, origen `flowly-design-tokens.json`):
  base paper `#EDEFEA`, ink `#191C19`, acento pine `#33564A`, acento secundario
  ámbar `#D9A441` / rosa `#B5675C`, más variantes pale/deep.

## Convenciones de estilo

- Comentarios y doc-comments en **español**.
- Material 3 (`useMaterial3`), null-safety estricto.
- Tokens de color/tipografía centralizados en `lib/app/theme/`, no valores
  literales esparcidos.
- Textos de la UI a través de l10n (`lib/l10n/*.arb`), **español como idioma
  por defecto** y `en` como alternativa. El mecanismo permite conmutar idioma
  aunque aún no haya control visual.

## Git

- Rama de trabajo: **`develop`** (los cambios se commitean aquí).
- Realizar **commits incrementales al completar cada apartado** implementado
  (por ejemplo: i18n, modelos, repositorio, pantalla, integración, tests), con
  mensaje en el estilo convencional (`feat:`, `fix:`, `refactor:`, `test:`, …),
  en español cuando se describa la funcionalidad.