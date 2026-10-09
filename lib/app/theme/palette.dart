import 'package:flutter/material.dart';

import 'colors.dart';

/// Paleta activa de la app como [ThemeExtension], para que cualquier widget
/// pueda resolver los tokens con `Palette.of(context)` en lugar de leer
/// colores fijos.
///
/// Hay dos instancias: [light] (los tokens de [AppColors]) y [dark] (los de
/// [AppColorsDark]). El tema correspondiente la registra en sus `extensions`,
/// así que [of] siempre devuelve la paleta correcta y, si alguien monta un
/// tema sin registrarla, cae en la clara.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.paper,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.line,
    required this.lineFaint,
    required this.cardBg,
    required this.onPrimary,
    required this.pine,
    required this.pineDeep,
    required this.pinePale,
    required this.amber,
    required this.amberPale,
    required this.rose,
    required this.rosePale,
    required this.done,
    required this.donePale,
    required this.missPale,
    required this.futurePale,
    required this.stageBg,
    required this.overviewBg,
    required this.navInactive,
    required this.columnGray,
    required this.columnGrayPale,
    required this.amberDeep,
    required this.roseDeep,
  });

  /// Paleta clara (tokens base, ver [AppColors]).
  static const Palette light = Palette(
    paper: AppColors.paper,
    ink: AppColors.ink,
    inkSoft: AppColors.inkSoft,
    inkFaint: AppColors.inkFaint,
    line: AppColors.line,
    lineFaint: AppColors.lineFaint,
    cardBg: AppColors.cardBg,
    onPrimary: AppColors.onPrimary,
    pine: AppColors.pine,
    pineDeep: AppColors.pineDeep,
    pinePale: AppColors.pinePale,
    amber: AppColors.amber,
    amberPale: AppColors.amberPale,
    rose: AppColors.rose,
    rosePale: AppColors.rosePale,
    done: AppColors.done,
    donePale: AppColors.donePale,
    missPale: AppColors.missPale,
    futurePale: AppColors.futurePale,
    stageBg: AppColors.stageBg,
    overviewBg: AppColors.overviewBg,
    navInactive: AppColors.navInactive,
    columnGray: AppColors.columnGray,
    columnGrayPale: AppColors.columnGrayPale,
    amberDeep: AppColors.amberDeep,
    roseDeep: AppColors.roseDeep,
  );

  /// Paleta oscura (bloque `dark` de los tokens, ver [AppColorsDark]).
  static const Palette dark = Palette(
    paper: AppColorsDark.paper,
    ink: AppColorsDark.ink,
    inkSoft: AppColorsDark.inkSoft,
    inkFaint: AppColorsDark.inkFaint,
    line: AppColorsDark.line,
    lineFaint: AppColorsDark.lineFaint,
    cardBg: AppColorsDark.cardBg,
    onPrimary: AppColorsDark.onPrimary,
    pine: AppColorsDark.pine,
    pineDeep: AppColorsDark.pineDeep,
    pinePale: AppColorsDark.pinePale,
    amber: AppColorsDark.amber,
    amberPale: AppColorsDark.amberPale,
    rose: AppColorsDark.rose,
    rosePale: AppColorsDark.rosePale,
    done: AppColorsDark.done,
    donePale: AppColorsDark.donePale,
    missPale: AppColorsDark.missPale,
    futurePale: AppColorsDark.futurePale,
    stageBg: AppColorsDark.stageBg,
    overviewBg: AppColorsDark.overviewBg,
    navInactive: AppColorsDark.navInactive,
    columnGray: AppColorsDark.columnGray,
    columnGrayPale: AppColorsDark.columnGrayPale,
    amberDeep: AppColorsDark.amberDeep,
    roseDeep: AppColorsDark.roseDeep,
  );

  /// Paleta registrada en el tema de [context]; si no hay, la clara.
  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>() ?? light;

  final Color paper;
  final Color ink;
  final Color inkSoft;
  final Color inkFaint;
  final Color line;
  final Color lineFaint;
  final Color cardBg;
  final Color onPrimary;
  final Color pine;
  final Color pineDeep;
  final Color pinePale;
  final Color amber;
  final Color amberPale;
  final Color rose;
  final Color rosePale;
  final Color done;
  final Color donePale;
  final Color missPale;
  final Color futurePale;
  final Color stageBg;
  final Color overviewBg;
  final Color navInactive;
  final Color columnGray;
  final Color columnGrayPale;
  final Color amberDeep;
  final Color roseDeep;

  /// Paleta de puntos de columna, en orden cíclico por índice.
  List<Color> get columnDots => [columnGray, rose, amber, pine];

  @override
  Palette copyWith({
    Color? paper,
    Color? ink,
    Color? inkSoft,
    Color? inkFaint,
    Color? line,
    Color? lineFaint,
    Color? cardBg,
    Color? onPrimary,
    Color? pine,
    Color? pineDeep,
    Color? pinePale,
    Color? amber,
    Color? amberPale,
    Color? rose,
    Color? rosePale,
    Color? done,
    Color? donePale,
    Color? missPale,
    Color? futurePale,
    Color? stageBg,
    Color? overviewBg,
    Color? navInactive,
    Color? columnGray,
    Color? columnGrayPale,
    Color? amberDeep,
    Color? roseDeep,
  }) {
    return Palette(
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      line: line ?? this.line,
      lineFaint: lineFaint ?? this.lineFaint,
      cardBg: cardBg ?? this.cardBg,
      onPrimary: onPrimary ?? this.onPrimary,
      pine: pine ?? this.pine,
      pineDeep: pineDeep ?? this.pineDeep,
      pinePale: pinePale ?? this.pinePale,
      amber: amber ?? this.amber,
      amberPale: amberPale ?? this.amberPale,
      rose: rose ?? this.rose,
      rosePale: rosePale ?? this.rosePale,
      done: done ?? this.done,
      donePale: donePale ?? this.donePale,
      missPale: missPale ?? this.missPale,
      futurePale: futurePale ?? this.futurePale,
      stageBg: stageBg ?? this.stageBg,
      overviewBg: overviewBg ?? this.overviewBg,
      navInactive: navInactive ?? this.navInactive,
      columnGray: columnGray ?? this.columnGray,
      columnGrayPale: columnGrayPale ?? this.columnGrayPale,
      amberDeep: amberDeep ?? this.amberDeep,
      roseDeep: roseDeep ?? this.roseDeep,
    );
  }

  @override
  Palette lerp(covariant Palette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      paper: mix(paper, other.paper),
      ink: mix(ink, other.ink),
      inkSoft: mix(inkSoft, other.inkSoft),
      inkFaint: mix(inkFaint, other.inkFaint),
      line: mix(line, other.line),
      lineFaint: mix(lineFaint, other.lineFaint),
      cardBg: mix(cardBg, other.cardBg),
      onPrimary: mix(onPrimary, other.onPrimary),
      pine: mix(pine, other.pine),
      pineDeep: mix(pineDeep, other.pineDeep),
      pinePale: mix(pinePale, other.pinePale),
      amber: mix(amber, other.amber),
      amberPale: mix(amberPale, other.amberPale),
      rose: mix(rose, other.rose),
      rosePale: mix(rosePale, other.rosePale),
      done: mix(done, other.done),
      donePale: mix(donePale, other.donePale),
      missPale: mix(missPale, other.missPale),
      futurePale: mix(futurePale, other.futurePale),
      stageBg: mix(stageBg, other.stageBg),
      overviewBg: mix(overviewBg, other.overviewBg),
      navInactive: mix(navInactive, other.navInactive),
      columnGray: mix(columnGray, other.columnGray),
      columnGrayPale: mix(columnGrayPale, other.columnGrayPale),
      amberDeep: mix(amberDeep, other.amberDeep),
      roseDeep: mix(roseDeep, other.roseDeep),
    );
  }
}
