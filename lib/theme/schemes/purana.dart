import 'package:flutter/material.dart';

import '../dpd_palette.dart';

// purāṇa — classic cyan/blue palette, identical to the original DpdColors values

final puranaLight = DpdPalette(
  primary: HSLColor.fromAHSL(1, 198, 1, 0.5).toColor(),
  primaryAlt: HSLColor.fromAHSL(1, 205, 1, 0.4).toColor(),
  primaryText: HSLColor.fromAHSL(1, 205, 0.79, 0.48).toColor(),
  primaryTextDark: HSLColor.fromAHSL(1, 205, 0.79, 0.56).toColor(),
  light: HSLColor.fromAHSL(1, 198, 1, 0.95).toColor(),
  lightShade: HSLColor.fromAHSL(1, 198, 1, 0.93).toColor(),
  dark: HSLColor.fromAHSL(1, 198, 1, 0.05).toColor(),
  darkShade: HSLColor.fromAHSL(1, 198, 1, 0.07).toColor(),
  gray: HSLColor.fromAHSL(1, 0, 0, 0.5).toColor(),
  grayLight: HSLColor.fromAHSL(1, 0, 0, 0.75).toColor(),
  grayDark: HSLColor.fromAHSL(1, 0, 0, 0.25).toColor(),
  grayTransparent: HSLColor.fromAHSL(0.25, 0, 0, 0.5).toColor(),
  secondary: HSLColor.fromAHSL(1, 158, 1, 0.35).toColor(),
  freq: [
    HSLColor.fromAHSL(0.1, 198, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.2, 200, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.3, 202, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.4, 204, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.5, 206, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.6, 208, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.7, 210, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.8, 212, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(0.9, 214, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(1, 216, 0.9, 0.5).toColor(),
    HSLColor.fromAHSL(1, 218, 0.9, 0.5).toColor(),
  ],
  accentRed: const Color(0xFFCC0000),
  accentRedDark: const Color(0xFFFF7070),
  accentGreen: const Color(0xFF007700),
  accentGreenDark: const Color(0xFF66CC66),
  accentOrange: const Color(0xFFBA4200),
  accentOrangeDark: const Color(0xFFE09050),
  accentPurple: const Color(0xFF800080),
  accentPurpleDark: const Color(0xFFC88CDC),
  accentBrown: const Color(0xFF8B4513),
  accentBrownDark: const Color(0xFFD29B69),
  shadowDefault: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.4, 0, 0, 0.2).toColor(),
    ),
  ],
  shadowHover: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.5, 0, 0, 0.2).toColor(),
    ),
  ],
);

// Dark variant shares the same accent colours — only bg/fg flip
final puranaDark = puranaLight;
