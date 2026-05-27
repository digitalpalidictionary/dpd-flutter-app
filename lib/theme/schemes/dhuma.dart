import 'package:flutter/material.dart';

import '../dpd_palette.dart';

// dhūma — smoke palette. Slightly cool off-white and near-black with layered
// slate-grays. The hue H=215 at very low saturation gives the atmospheric
// quality of smoke without an obvious color.

final dhumaLight = DpdPalette(
  primary: HSLColor.fromAHSL(1, 215, 0.18, 0.56).toColor(),
  primaryAlt: HSLColor.fromAHSL(1, 215, 0.20, 0.30).toColor(),
  primaryText: HSLColor.fromAHSL(1, 215, 0.18, 0.40).toColor(),
  primaryTextDark: HSLColor.fromAHSL(1, 215, 0.18, 0.44).toColor(),
  light: HSLColor.fromAHSL(1, 215, 0.06, 0.96).toColor(),
  lightShade: HSLColor.fromAHSL(1, 215, 0.06, 0.92).toColor(),
  dark: HSLColor.fromAHSL(1, 215, 0.10, 0.12).toColor(),
  darkShade: HSLColor.fromAHSL(1, 215, 0.10, 0.16).toColor(),
  gray: HSLColor.fromAHSL(1, 215, 0.04, 0.70).toColor(),
  grayLight: HSLColor.fromAHSL(1, 215, 0.03, 0.84).toColor(),
  grayDark: HSLColor.fromAHSL(1, 215, 0.07, 0.32).toColor(),
  grayTransparent: HSLColor.fromAHSL(0.25, 215, 0.04, 0.70).toColor(),
  secondary: HSLColor.fromAHSL(1, 200, 0.12, 0.40).toColor(),
  freq: [
    HSLColor.fromAHSL(0.1, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.2, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.3, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.4, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.5, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.6, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.7, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.8, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(0.9, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(1.0, 215, 0.15, 0.42).toColor(),
    HSLColor.fromAHSL(1.0, 215, 0.15, 0.42).toColor(),
  ],
  accentRed: const Color(0xFF7A3030),
  accentRedDark: const Color(0xFFC07070),
  accentGreen: const Color(0xFF2E5030),
  accentGreenDark: const Color(0xFF70A070),
  accentOrange: const Color(0xFF7A5025),
  accentOrangeDark: const Color(0xFFC09858),
  accentPurple: const Color(0xFF504878),
  accentPurpleDark: const Color(0xFF9888B8),
  accentBrown: const Color(0xFF584030),
  accentBrownDark: const Color(0xFFA07858),
  shadowDefault: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.35, 215, 0.10, 0.20).toColor(),
    ),
  ],
  shadowHover: [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.50, 215, 0.10, 0.20).toColor(),
    ),
  ],
);

final dhumaDark = DpdPalette(
  primary: HSLColor.fromAHSL(1, 215, 0.22, 0.65).toColor(),
  primaryAlt: HSLColor.fromAHSL(1, 215, 0.20, 0.52).toColor(),
  primaryText: HSLColor.fromAHSL(1, 215, 0.25, 0.70).toColor(),
  primaryTextDark: HSLColor.fromAHSL(1, 215, 0.25, 0.70).toColor(),
  light: HSLColor.fromAHSL(1, 215, 0.08, 0.88).toColor(),
  lightShade: HSLColor.fromAHSL(1, 215, 0.06, 0.82).toColor(),
  dark: HSLColor.fromAHSL(1, 215, 0.14, 0.09).toColor(),
  darkShade: HSLColor.fromAHSL(1, 215, 0.14, 0.13).toColor(),
  gray: HSLColor.fromAHSL(1, 215, 0.07, 0.50).toColor(),
  grayLight: HSLColor.fromAHSL(1, 215, 0.05, 0.62).toColor(),
  grayDark: HSLColor.fromAHSL(1, 215, 0.09, 0.35).toColor(),
  grayTransparent: HSLColor.fromAHSL(0.25, 215, 0.07, 0.50).toColor(),
  secondary: HSLColor.fromAHSL(1, 200, 0.15, 0.55).toColor(),
  freq: [
    HSLColor.fromAHSL(0.1, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.2, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.3, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.4, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.5, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.6, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.7, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.8, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(0.9, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(1.0, 215, 0.20, 0.65).toColor(),
    HSLColor.fromAHSL(1.0, 215, 0.20, 0.65).toColor(),
  ],
  accentRed: const Color(0xFFBB6060),
  accentRedDark: const Color(0xFFDD9090),
  accentGreen: const Color(0xFF60A060),
  accentGreenDark: const Color(0xFF90C090),
  accentOrange: const Color(0xFFB88848),
  accentOrangeDark: const Color(0xFFD8B078),
  accentPurple: const Color(0xFF9080B8),
  accentPurpleDark: const Color(0xFFB8A8D0),
  accentBrown: const Color(0xFF907060),
  accentBrownDark: const Color(0xFFBB9880),
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
