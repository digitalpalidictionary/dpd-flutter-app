# Spec: Switchable Colour Schemes

## Overview
Add user-selectable colour schemes to the DPD Flutter app, starting with three:
- **purāṇa** — current cyan/blue palette (renamed, unchanged)
- **kasāya** — Kimbie-inspired monk-robe palette (warm browns/ochre/burnt orange)
- **tālapaṇṇa** — palm-leaf manuscript palette inspired by the Digital Pali Reader (cream/off-white light, warm-dark variant)

Each scheme has a light and dark variant; the existing brightness mode (light/dark/system) continues to drive which variant is shown. Switching schemes must apply instantly to every part of the app (settings, search, entry, root, dialogs, popups, sheets, snackbars).

The architecture must accommodate adding more schemes later without touching the call sites — i.e. *one* place to register a new scheme.

## Repo context
- Theme constants live as a static class in `lib/theme/dpd_colors.dart` (`DpdColors.primary`, `.light`, `.dark`, etc. — ~30 named colours plus `freq[]`, `accent*` pairs, shadows, `borderRadius`, `sectionPadding`).
- `lib/app.dart:140-172` hand-builds `lightScheme` / `darkScheme` `ColorScheme`s from those statics.
- **185 direct `DpdColors.X` references across 32 files.** Theme switching cannot work instantly unless these are converted to theme-aware lookups.
- Settings model: `lib/providers/settings_provider.dart` — already persists `themeMode`, `useSerifFont`, etc. via `SharedPreferences`.
- Settings UI: `lib/widgets/settings_panel.dart` — the brightness toggle lives here; user wants the scheme selector adjacent.

## What it should do
1. A new `Settings.colourScheme` field (enum: `purana | kasaya | talapanna`), persisted in SharedPreferences, default `purana`.
2. A three-way selector in the Settings panel **next to the existing light/dark/system toggle**. Tapping a scheme switches the entire app instantly. Tapping rapidly between schemes is the "compare" affordance.
3. `DpdColors` is reorganised so that all *theme-dependent* values (colours, shadows, freq heatmap, accents) move into a new `DpdPalette extends ThemeExtension<DpdPalette>`. Theme-independent constants (`borderRadius`, `borderRadiusValue`, `sectionPadding`) stay.
4. All 185 call sites convert from `DpdColors.primary` → `context.palette.primary` (via a `BuildContext` extension for ergonomics).
5. `ThemeData` in `app.dart` is rebuilt per active scheme, pulling palette colours into the `ColorScheme` and injecting `DpdPalette` as a theme extension.
6. Brightness mode (light/dark/system) continues to work and combines with scheme selection.

## Scheme definitions

### purāṇa (existing — unchanged)
Light: bg `hsl(198,100%,95%)`, accent cyan `hsl(198,100%,50%)`.
Dark: bg `hsl(198,100%,5%)`, same accents.

### kasāya (new — Kimbie-inspired monk robe)
Dark: bg `#221a0f` (deep brown-black), fg `#d3af86` (warm cream), accent burnt orange `#f06431`.
Light: bg `#f8eedb` (warm cream), fg `#3c2a1e` (deep brown), accent `#a05a2c` burnt sienna.

### tālapaṇṇa (new — palm-leaf manuscript, DPR-inspired)
Light: bg `#f5ecd6` (off-white cream), fg `#3a2e1f`, accent `#7a5a2c` muted brown.
Dark: bg `#1c1812` (warm near-black), fg `#d8c9a3` (faded cream), accent `#a89072` muted tan.

## Assumptions & uncertainties
- `borderRadius`, `borderRadiusValue`, `sectionPadding` are not theme-dependent — stay as statics.
- `freq[]` heatmap and `accent*` pairs are theme-dependent — re-mapped per scheme.
- The existing `_switchTheme` should also become palette-aware.
- No existing tests will break — there are no UI tests per project policy.

## Constraints
- No hardcoded `Colors.X` — already a project rule.
- All `DpdColors.X` colour call sites must be converted.
- Adding a 4th scheme later requires only adding one file + one enum value, not editing call sites.
- Selector UI lives next to the brightness toggle (user-confirmed).

## How we'll know it's done
- Tapping each scheme chip instantly recolours the visible Settings panel and all other screens.
- Brightness toggle still works independently.
- Setting persists across app restarts.
- `rg "DpdColors\.(primary|primaryAlt|primaryText|light|lightShade|dark|darkShade|gray|secondary|freq|accent|shadow)" lib/` returns zero matches.
- `flutter analyze` clean.

## What's not included
- A floating in-page compare button.
- Auto-derived schemes.
- Per-screen scheme overrides.
