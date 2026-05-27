import 'package:flutter/material.dart';

import '../dpd_palette.dart';

// kapila — tawny/golden palette. Warm parchment-cream backgrounds with vivid
// golden-copper accents in light mode. Deep warm near-black with copper-gold
// highlights in dark mode.

final kapilaLight = DpdPalette(
  primary: HSLColor.fromAHSL(1, 34, 0.65, 0.46).toColor(),
  primaryAlt: HSLColor.fromAHSL(1, 34, 0.68, 0.30).toColor(),
  primaryText: HSLColor.fromAHSL(1, 34, 0.62, 0.36).toColor(),
  primaryTextDark: HSLColor.fromAHSL(1, 34, 0.62, 0.42).toColor(),
  light: const Color(0xFFF5ECD6),
  lightShade: const Color(0xFFEDE0C4),
  dark: HSLColor.fromAHSL(1, 34, 0.22, 0.11).toColor(),
  darkShade: HSLColor.fromAHSL(1, 34, 0.20, 0.15).toColor(),
  gray: HSLColor.fromAHSL(1, 34, 0.10, 0.55).toColor(),
  grayLight: HSLColor.fromAHSL(1, 34, 0.08, 0.75).toColor(),
  grayDark: HSLColor.fromAHSL(1, 34, 0.12, 0.32).toColor(),
  grayTransparent: HSLColor.fromAHSL(0.25, 34, 0.10, 0.55).toColor(),
  secondary: HSLColor.fromAHSL(1, 22, 0.28, 0.40).toColor(),
  freq: [
    HSLColor.fromAHSL(0.1, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.2, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.3, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.4, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.5, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.6, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.7, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.8, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(0.9, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(1.0, 34, 0.65, 0.46).toColor(),
    HSLColor.fromAHSL(1.0, 34, 0.65, 0.46).toColor(),
  ],
  accentRed: const Color(0xFF8B2A1A),
  accentRedDark: const Color(0xFFCC6050),
  accentGreen: const Color(0xFF3A5A1A),
  accentGreenDark: const Color(0xFF78A850),
  accentOrange: const Color(0xFF8A4A10),
  accentOrangeDark: const Color(0xFFC89040),
  accentPurple: const Color(0xFF5A3870),
  accentPurpleDark: const Color(0xFF9870B8),
  accentBrown: const Color(0xFF6A4818),
  accentBrownDark: const Color(0xFFC09050),
  shadowDefault: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.35, 34, 0.22, 0.18).toColor(),
    ),
  ],
  shadowHover: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.50, 34, 0.22, 0.18).toColor(),
    ),
  ],
);

final kapilaDark = DpdPalette(
  primary: HSLColor.fromAHSL(1, 34, 0.60, 0.50).toColor(),
  primaryAlt: HSLColor.fromAHSL(1, 34, 0.55, 0.36).toColor(),
  primaryText: HSLColor.fromAHSL(1, 34, 0.65, 0.62).toColor(),
  primaryTextDark: HSLColor.fromAHSL(1, 34, 0.65, 0.62).toColor(),
  light: HSLColor.fromAHSL(1, 34, 0.18, 0.87).toColor(),
  lightShade: HSLColor.fromAHSL(1, 34, 0.14, 0.78).toColor(),
  dark: HSLColor.fromAHSL(1, 34, 0.22, 0.09).toColor(),
  darkShade: HSLColor.fromAHSL(1, 34, 0.22, 0.13).toColor(),
  gray: HSLColor.fromAHSL(1, 34, 0.10, 0.50).toColor(),
  grayLight: HSLColor.fromAHSL(1, 34, 0.08, 0.62).toColor(),
  grayDark: HSLColor.fromAHSL(1, 34, 0.12, 0.35).toColor(),
  grayTransparent: HSLColor.fromAHSL(0.25, 34, 0.10, 0.50).toColor(),
  secondary: HSLColor.fromAHSL(1, 22, 0.30, 0.52).toColor(),
  freq: [
    HSLColor.fromAHSL(0.1, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.2, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.3, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.4, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.5, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.6, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.7, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.8, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(0.9, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(1.0, 34, 0.60, 0.50).toColor(),
    HSLColor.fromAHSL(1.0, 34, 0.60, 0.50).toColor(),
  ],
  accentRed: const Color(0xFFCC6050),
  accentRedDark: const Color(0xFFEE9080),
  accentGreen: const Color(0xFF70A840),
  accentGreenDark: const Color(0xFF98C868),
  accentOrange: const Color(0xFFB88030),
  accentOrangeDark: const Color(0xFFD8A858),
  accentPurple: const Color(0xFF9070B8),
  accentPurpleDark: const Color(0xFFB898D0),
  accentBrown: const Color(0xFFA07838),
  accentBrownDark: const Color(0xFFC8A060),
  shadowDefault: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.5),
    ),
  ],
  shadowHover: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.6),
    ),
  ],
);
