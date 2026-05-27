# Spec: dhūma colour scheme

## Overview
Add a third colour scheme called **dhūma** (Pāḷi: smoke) — a monochrome palette built
from slightly cool off-white, near-black, and layered slate-grays. The scheme appears
as a third option in the Settings colour-scheme selector alongside nīla and kapila.

## Repo context
- Schemes live in `lib/theme/schemes/`. Each is a `.dart` file exporting a light and
  dark `DpdPalette`.
- `lib/theme/dpd_scheme.dart` holds the `DpdScheme` enum, label extension, and
  `palettesFor()` switch. Adding a scheme requires: one new file + three lines here.
- Settings UI: `lib/widgets/settings_panel.dart` — the scheme selector iterates
  `DpdScheme.values` automatically via `s.label`; no structural change needed.
  Only the help-text string describing the schemes needs updating.
- The `DpdPalette` struct is fixed — no new fields needed.

## Design rationale (why this isn't boring)
Pure neutral gray is flat. dhūma avoids this with two techniques:
1. **Subtle cool hue** — every color uses H=215 (blue-slate) with very low saturation
   (3–22%). This gives the slight atmospheric quality of smoke/mist without any
   obvious color.
2. **Strong tonal contrast** — off-white (#F4F5F7) background vs. near-black
   (#1E2124) text creates clean, readable contrast with no muddiness.
3. **Primary as the sole accent** — slate-pewter (#58687E) is the only "colored"
   thing. It reads as interactive without fighting the neutral palette.
4. **Muted accents** — reds, greens, etc. are desaturated to ~30–50% of their
   original saturation, keeping semantic function without color clash.

## What it should do
1. A new `DpdScheme.dhuma` enum value with label `'dhūma'`.
2. Light palette: very slightly cool off-white bg, near-black text, slate-pewter
   interactive color, muted accent colors.
3. Dark palette: near-black bg with slight blue, off-white text, lighter slate for
   interactive, muted lighter accents.
4. `palettesFor(DpdScheme.dhuma)` returns these palettes.
5. Scheme selector in settings shows `dhūma` as a third option and applies instantly.

## Assumptions & uncertainties
- No new `DpdPalette` fields needed — all existing fields have clear monochrome
  equivalents.
- The `freq[]` array of 11 colors is used for frequency heatmaps; in dhūma these
  will be opacity-stepped slate tones (same hue, alpha 0.1 → 1.0).
- Accent colors are kept distinct enough to remain functionally meaningful.
- `puranaDark = puranaLight` (same palette for both modes) is deliberate for purāṇa;
  dhūma will have a proper separate dark palette for quality.

## Constraints
- No hardcoded `Colors.X` — use `HSLColor.fromAHSL` or `const Color(0xFFXXXXXX)`.
- Follow exactly the same file/variable naming pattern as `kapila.dart`.
- Label string must include the macron: `'dhūma'`.

## How we'll know it's done
- Settings panel shows three scheme options: nīla, kapila, dhūma.
- Selecting dhūma applies a clean gray theme instantly in both light and dark modes.
- `flutter analyze` reports no issues.

## What's not included
- Any changes to existing schemes.
- Any new DpdPalette fields.
- Automatic scheme migration for users on old preferences (not needed — unknown
  enum names fall back to `nila` via `orElse`).
