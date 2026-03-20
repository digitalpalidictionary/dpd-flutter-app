import 'package:flutter/material.dart';

/// Color constants matching the DPD webapp CSS variables in dpd.css.
/// HSL values are converted to Flutter Color using HSLColor.
abstract final class DpdColors {
  // Primary accent — borders, buttons, accents
  // --primary: hsl(198, 100%, 50%)
  static final Color primary = HSLColor.fromAHSL(1, 198, 1, 0.5).toColor();

  // Pressed/hover state
  // --primary-alt: hsl(205, 100%, 40%)
  static final Color primaryAlt = HSLColor.fromAHSL(1, 205, 1, 0.4).toColor();

  // Readable accent text
  // --primary-text: hsl(205, 79%, 48%)
  static final Color primaryText = HSLColor.fromAHSL(
    1,
    205,
    0.79,
    0.48,
  ).toColor();

  // Lighter variant for dark backgrounds
  // --primary-text dark: hsl(205, 79%, 65%)
  static final Color primaryTextDark = HSLColor.fromAHSL(
    1,
    205,
    0.79,
    0.56,
  ).toColor();

  // Light mode backgrounds
  // --light: hsl(198, 100%, 95%)
  static final Color light = HSLColor.fromAHSL(1, 198, 1, 0.95).toColor();

  // --light-shade: hsl(198, 100%, 93%)
  static final Color lightShade = HSLColor.fromAHSL(1, 198, 1, 0.93).toColor();

  // Dark mode backgrounds
  // --dark: hsl(198, 100%, 5%)
  static final Color dark = HSLColor.fromAHSL(1, 198, 1, 0.05).toColor();

  // --dark-shade: hsl(198, 100%, 7%)
  static final Color darkShade = HSLColor.fromAHSL(1, 198, 1, 0.07).toColor();

  // Grays
  // --gray: hsl(0, 0%, 50%)
  static final Color gray = HSLColor.fromAHSL(1, 0, 0, 0.5).toColor();

  // --gray-light: hsl(0, 0%, 75%)
  static final Color grayLight = HSLColor.fromAHSL(1, 0, 0, 0.75).toColor();

  // --gray-dark: hsl(0, 0%, 25%)
  static final Color grayDark = HSLColor.fromAHSL(1, 0, 0, 0.25).toColor();

  // --gray-transparent: hsla(0, 0%, 50%, 0.25)
  static final Color grayTransparent = HSLColor.fromAHSL(
    0.25,
    0,
    0,
    0.5,
  ).toColor();

  // Shadows
  // --shadow-default: 2px 2px 4px hsla(0, 0%, 20%, 0.4)
  static final List<BoxShadow> shadowDefault = [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.4, 0, 0, 0.2).toColor(),
    ),
  ];

  // --shadow-hover: 2px 2px 4px hsla(0, 0%, 20%, 0.5)
  static final List<BoxShadow> shadowHover = [
    BoxShadow(
      offset: const Offset(2, 2),
      blurRadius: 4,
      color: HSLColor.fromAHSL(0.5, 0, 0, 0.2).toColor(),
    ),
  ];

  // Secondary — help and abbreviations
  // --secondary: hsl(158, 100%, 35%)
  static final Color secondary = HSLColor.fromAHSL(1, 158, 1, 0.35).toColor();

  // Frequency heatmap (10 levels)
  static final List<Color> freq = [
    HSLColor.fromAHSL(0.1, 198, 0.9, 0.5).toColor(), // freq0
    HSLColor.fromAHSL(0.2, 200, 0.9, 0.5).toColor(), // freq1
    HSLColor.fromAHSL(0.3, 202, 0.9, 0.5).toColor(), // freq2
    HSLColor.fromAHSL(0.4, 204, 0.9, 0.5).toColor(), // freq3
    HSLColor.fromAHSL(0.5, 206, 0.9, 0.5).toColor(), // freq4
    HSLColor.fromAHSL(0.6, 208, 0.9, 0.5).toColor(), // freq5
    HSLColor.fromAHSL(0.7, 210, 0.9, 0.5).toColor(), // freq6
    HSLColor.fromAHSL(0.8, 212, 0.9, 0.5).toColor(), // freq7
    HSLColor.fromAHSL(0.9, 214, 0.9, 0.5).toColor(), // freq8
    HSLColor.fromAHSL(1, 216, 0.9, 0.5).toColor(), // freq9
    HSLColor.fromAHSL(1, 218, 0.9, 0.5).toColor(), // freq10
  ];

  // Dictionary accent colors (light / dark pairs)
  static final Color accentRed = const Color(0xFFCC0000);
  static final Color accentRedDark = const Color(0xFFFF7070);
  static final Color accentGreen = const Color(0xFF007700);
  static final Color accentGreenDark = const Color(0xFF66CC66);
  static final Color accentOrange = const Color(0xFFBA4200);
  static final Color accentOrangeDark = const Color(0xFFE09050);
  static final Color accentPurple = const Color(0xFF800080);
  static final Color accentPurpleDark = const Color(0xFFC88CDC);
  static final Color accentBrown = const Color(0xFF8B4513);
  static final Color accentBrownDark = const Color(0xFFD29B69);

  // Visual Styling Constants
  // Match the visual weight of webapp's 7px radius.
  static const double borderRadiusValue = 7.0;
  static final BorderRadius borderRadius = BorderRadius.circular(
    borderRadiusValue,
  );

  // Global padding for section content (Grammar, Examples, Families, etc.)
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 10.0,
    vertical: 3.0,
  );
}
