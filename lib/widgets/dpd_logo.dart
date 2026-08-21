import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The DPD brand mark rendered purely as code: a circle with "dpd" set in
/// Inter Bold. This reproduces `identity/logo/dpd-icon.svg` (verified
/// pixel-identical against the source SVG) with no asset or mask — so it scales
/// to any size and tints to any theme.
///
/// The label auto-contrasts against the circle (black on light circles, white
/// on dark ones) so it stays legible in every theme and brightness — e.g. black
/// on amber rather than white. Pass [textColor]/[circleColor] to override.
class DpdLogo extends StatelessWidget {
  const DpdLogo({
    super.key,
    required this.size,
    this.filled = true,
    this.circleColor,
    this.textColor,
  });

  final double size;

  /// A filled disc (default) matching the in-app logo, or an outline ring
  /// matching the bare brand icon.
  final bool filled;

  /// Circle colour; defaults to the theme's primary.
  final Color? circleColor;

  /// Label colour; defaults to an auto-contrasting black/white for [filled],
  /// or the circle colour for the outline variant.
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final circle = circleColor ?? Theme.of(context).colorScheme.primary;
    final label = textColor ??
        (filled ? contrastOn(circle) : circle);
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? circle : null,
          border: filled
              ? null
              : Border.all(color: circle, width: size * 0.031),
        ),
        child: Center(
          child: Text(
            'dpd',
            textAlign: TextAlign.center,
            // A brand mark, not body text: its proportions come from [size], so
            // letting the system font scale grow the label clips it to "d".
            textScaler: TextScaler.noScaling,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: size * 0.39,
              height: 1.0,
              color: label,
            ),
          ),
        ),
      ),
    );
  }

  /// Black on light colours, white on dark ones — whichever contrasts better.
  static Color contrastOn(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.light
          ? Colors.black
          : Colors.white;
}
