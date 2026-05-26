import 'package:flutter/material.dart';

import '../dpd_palette.dart';

// kapila — tawny/copper palette. Warm parchment cream backgrounds, muted
// copper-brown accents. Inspired by tālapaṇṇa with deeper copper tones.

final kapilaLight = DpdPalette(
  primary: const Color(0xFF8B5E3C),
  primaryAlt: const Color(0xFF6A4020),
  primaryText: const Color(0xFF7A4E28),
  primaryTextDark: const Color(0xFF7A4E28),
  light: const Color(0xFFF5ECD6),
  lightShade: const Color(0xFFEDE0C4),
  dark: const Color(0xFF3A2E1F),
  darkShade: const Color(0xFF473A28),
  gray: const Color(0xFF8A7A68),
  grayLight: const Color(0xFFBAAA98),
  grayDark: const Color(0xFF5A4A38),
  grayTransparent: Color.fromRGBO(138, 122, 104, 0.25),
  secondary: const Color(0xFF4A6840),
  freq: [
    HSLColor.fromAHSL(0.1, 25, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.2, 26, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.3, 27, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.4, 28, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.5, 29, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.6, 30, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.7, 31, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.8, 32, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(0.9, 33, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(1.0, 34, 0.75, 0.48).toColor(),
    HSLColor.fromAHSL(1.0, 35, 0.75, 0.48).toColor(),
  ],
  accentRed: const Color(0xFF993020),
  accentRedDark: const Color(0xFFBB6050),
  accentGreen: const Color(0xFF3A5A28),
  accentGreenDark: const Color(0xFF688050),
  accentOrange: const Color(0xFF8A5020),
  accentOrangeDark: const Color(0xFFBB8048),
  accentPurple: const Color(0xFF6A4870),
  accentPurpleDark: const Color(0xFF9A78A0),
  accentBrown: const Color(0xFF6B4820),
  accentBrownDark: const Color(0xFF9A7850),
  shadowDefault: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: Color.fromRGBO(58, 46, 31, 0.35),
    ),
  ],
  shadowHover: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: Color.fromRGBO(58, 46, 31, 0.5),
    ),
  ],
);

final kapilaDark = DpdPalette(
  primary: const Color(0xFFB87840),
  primaryAlt: const Color(0xFF9A6030),
  primaryText: const Color(0xFFD4A870),
  primaryTextDark: const Color(0xFFD4A870),
  light: const Color(0xFFD8C9A3),
  lightShade: const Color(0xFFC8B890),
  dark: const Color(0xFF1C1812),
  darkShade: const Color(0xFF242018),
  gray: const Color(0xFF786858),
  grayLight: const Color(0xFFA09080),
  grayDark: const Color(0xFF504038),
  grayTransparent: Color.fromRGBO(120, 104, 88, 0.25),
  secondary: const Color(0xFF708858),
  freq: [
    HSLColor.fromAHSL(0.1, 28, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.2, 29, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.3, 30, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.4, 31, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.5, 32, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.6, 33, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.7, 34, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.8, 35, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(0.9, 36, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(1.0, 37, 0.65, 0.55).toColor(),
    HSLColor.fromAHSL(1.0, 38, 0.65, 0.55).toColor(),
  ],
  accentRed: const Color(0xFFCC6050),
  accentRedDark: const Color(0xFFEE9080),
  accentGreen: const Color(0xFF708858),
  accentGreenDark: const Color(0xFF98AA80),
  accentOrange: const Color(0xFFC09060),
  accentOrangeDark: const Color(0xFFE0B888),
  accentPurple: const Color(0xFF9878A8),
  accentPurpleDark: const Color(0xFFC0A8D0),
  accentBrown: const Color(0xFFA08060),
  accentBrownDark: const Color(0xFFD0B090),
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
