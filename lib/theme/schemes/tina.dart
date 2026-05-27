import 'package:flutter/material.dart';

import '../dpd_palette.dart';

// tiṇa — fresh grass palette. H=115 (natural grass green) at low-to-medium
// saturation. Light mode: barely-green off-white with fresh green accents.
// Dark mode: near-black with strong green saturation — dark forest floor.

final tinaLight = DpdPalette(
  primary: HSLColor.fromAHSL(1, 115, 0.40, 0.48).toColor(),
  primaryAlt: HSLColor.fromAHSL(1, 115, 0.42, 0.32).toColor(),
  primaryText: HSLColor.fromAHSL(1, 115, 0.38, 0.34).toColor(),
  primaryTextDark: HSLColor.fromAHSL(1, 115, 0.38, 0.42).toColor(),
  light: HSLColor.fromAHSL(1, 115, 0.08, 0.96).toColor(),
  lightShade: HSLColor.fromAHSL(1, 115, 0.08, 0.92).toColor(),
  dark: HSLColor.fromAHSL(1, 115, 0.15, 0.10).toColor(),
  darkShade: HSLColor.fromAHSL(1, 115, 0.15, 0.14).toColor(),
  gray: HSLColor.fromAHSL(1, 115, 0.06, 0.55).toColor(),
  grayLight: HSLColor.fromAHSL(1, 115, 0.04, 0.75).toColor(),
  grayDark: HSLColor.fromAHSL(1, 115, 0.08, 0.32).toColor(),
  grayTransparent: HSLColor.fromAHSL(0.25, 115, 0.06, 0.55).toColor(),
  secondary: HSLColor.fromAHSL(1, 130, 0.22, 0.38).toColor(),
  freq: [
    HSLColor.fromAHSL(0.1, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.2, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.3, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.4, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.5, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.6, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.7, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.8, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(0.9, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(1.0, 115, 0.40, 0.46).toColor(),
    HSLColor.fromAHSL(1.0, 115, 0.40, 0.46).toColor(),
  ],
  accentRed: const Color(0xFF7A2828),
  accentRedDark: const Color(0xFFBB6060),
  accentGreen: const Color(0xFF226022),
  accentGreenDark: const Color(0xFF58A058),
  accentOrange: const Color(0xFF7A5A18),
  accentOrangeDark: const Color(0xFFBB9848),
  accentPurple: const Color(0xFF486858),
  accentPurpleDark: const Color(0xFF88A888),
  accentBrown: const Color(0xFF5A4828),
  accentBrownDark: const Color(0xFF9A8058),
  shadowDefault: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.35, 115, 0.15, 0.15).toColor(),
    ),
  ],
  shadowHover: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.50, 115, 0.15, 0.15).toColor(),
    ),
  ],
);

final tinaDark = DpdPalette(
  primary: HSLColor.fromAHSL(1, 115, 0.45, 0.40).toColor(),
  primaryAlt: HSLColor.fromAHSL(1, 115, 0.42, 0.28).toColor(),
  primaryText: HSLColor.fromAHSL(1, 115, 0.50, 0.55).toColor(),
  primaryTextDark: HSLColor.fromAHSL(1, 115, 0.50, 0.55).toColor(),
  light: HSLColor.fromAHSL(1, 115, 0.10, 0.88).toColor(),
  lightShade: HSLColor.fromAHSL(1, 115, 0.08, 0.80).toColor(),
  dark: HSLColor.fromAHSL(1, 120, 0.25, 0.07).toColor(),
  darkShade: HSLColor.fromAHSL(1, 120, 0.25, 0.11).toColor(),
  gray: HSLColor.fromAHSL(1, 115, 0.08, 0.48).toColor(),
  grayLight: HSLColor.fromAHSL(1, 115, 0.06, 0.62).toColor(),
  grayDark: HSLColor.fromAHSL(1, 115, 0.10, 0.32).toColor(),
  grayTransparent: HSLColor.fromAHSL(0.25, 115, 0.08, 0.48).toColor(),
  secondary: HSLColor.fromAHSL(1, 130, 0.30, 0.55).toColor(),
  freq: [
    HSLColor.fromAHSL(0.1, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.2, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.3, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.4, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.5, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.6, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.7, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.8, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(0.9, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(1.0, 115, 0.50, 0.60).toColor(),
    HSLColor.fromAHSL(1.0, 115, 0.50, 0.60).toColor(),
  ],
  accentRed: const Color(0xFFBB5050),
  accentRedDark: const Color(0xFFDD9080),
  accentGreen: const Color(0xFF58B058),
  accentGreenDark: const Color(0xFF88D088),
  accentOrange: const Color(0xFFB08838),
  accentOrangeDark: const Color(0xFFD8B060),
  accentPurple: const Color(0xFF789888),
  accentPurpleDark: const Color(0xFFA8C0A8),
  accentBrown: const Color(0xFF907050),
  accentBrownDark: const Color(0xFFBB9870),
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
