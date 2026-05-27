# Plan: dhūma colour scheme

## Architecture Decisions
- Follow the `kapila.dart` pattern exactly: one file exports `dhumaLight` and
  `dhumaDark` palettes; `dpd_scheme.dart` wires it in.
- Separate light and dark palettes (not the `puranaDark = puranaLight` shortcut)
  because a proper dark mode needs a lighter primary and different grays.
- All colors expressed as `HSLColor.fromAHSL` to show design intent, except accents
  which use `const Color(0xFF...)` for clarity.
- Hue H=215 used throughout at very low saturation (3–22%) for the "smoke" quality.

## Phase 1 — Implement dhūma

- [x] Create `lib/theme/schemes/dhuma.dart` with `dhumaLight` and `dhumaDark` palettes
      → verify: `flutter analyze lib/theme/schemes/dhuma.dart` — no errors ✓

- [x] Register scheme in `lib/theme/dpd_scheme.dart`
      → verify: `flutter analyze lib/theme/dpd_scheme.dart` — no errors ✓

- [x] Update scheme help text in `lib/widgets/settings_panel.dart`
      → verify: `flutter analyze` — zero issues ✓
