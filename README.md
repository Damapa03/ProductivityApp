<<<<<<< HEAD
# ProductivityApp
App for increasing productivity
=======
# Flowly — Productividad y buenos hábitos

> Aplicación multiplataforma (Android, iOS, Web, Windows, macOS, Linux) para
> fomentar la productividad, los buenos hábitos y el deep-work. Flutter +
> Material 3.

## Estado del proyecto

**En curso.** Mockups de las 7–8 pantallas en `/mockups` (`01-login` … `07-profile`)
y token de diseño en `flowly-design-tokens.json`. Implementada hasta ahora:

- `LoginScreen` (`lib/features/login/login_screen.dart`): email, contraseña con
  subrayado, "Log in", divisores y botones sociales (Google / Apple), además del
  enlace "Create an account" y wordmark de marca.
- Tokens de color y tipografía (`lib/app/theme/`) con **Space Grotesk** e
  **IBM Plex Sans** embebidas como fuentes.

## Arquitectura

```
lib/
├── app/
│   ├── app.dart              # MaterialApp + rutas
│   └── theme/                # tokens: colors, text_styles, app_theme
├── features/
│   └── login/
│       └── login_screen.dart # pantalla de login
├── widgets/
│   ├── brand_mark.dart       # glifo de 4 barras + wordmark
│   ├── social_button.dart    # botones Google / Apple
│   └── underline_field.dart  # campo con subrayado
└── main.dart                 # entrada de la app
```

## Persistencia

**Diseño previsto (fase posterior):**

1. Persistencia local (p. ej. `shared_preferences` o `hive`) mientras se valida
   el flujo de UI.
2. Capa de datos desacoplada (`repository` + modelo) para que la migración a una
   **API externa** —que será la que realice la persistencia definitiva de
   tareas, hábitos y temporizadores— no implique reescribir la UI.

El contrato de datos se mantendrá estable entre ambas fases.

## Desarrollo

```bash
flutter pub get     # descargar dependencias y fuentes
flutter run         # lanzar en el dispositivo / emulador activo
flutter analyze     # verificación estática
flutter test        # tests
```

## Paleta

Tokens completos en `flowly-design-tokens.json` (base `#EDEFEA`, acento pine
`#33564A`, acento secundario ámbar / rosa).
>>>>>>> develop
