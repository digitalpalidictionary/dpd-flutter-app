# Plan: Switchable Colour Schemes

## Architecture Decisions
1. **`ThemeExtension<DpdPalette>`** is the mechanism — Flutter's blessed pattern for app-specific palettes.
2. **One file per scheme** under `lib/theme/schemes/` exporting `(DpdPalette light, DpdPalette dark)`. Adding scheme #4 = one file + one enum value.
3. **`context.palette` extension** for ergonomic access instead of verbose `Theme.of(context).extension<DpdPalette>()!`.
4. **Visual constants stay** — `borderRadius`, `borderRadiusValue`, `sectionPadding` stay as statics on `DpdColors`.
5. **`ColorScheme` in `app.dart`** derived from active `DpdPalette` so framework widgets get themed.
6. **Migration approach**: introduce `DpdPalette` + `context.palette` first, then convert call sites in batches.

## Phases

### Phase 1 — Palette foundation
- [x] Create `lib/theme/dpd_palette.dart` defining `class DpdPalette extends ThemeExtension<DpdPalette>` with all theme-dependent fields.
  → verify: `flutter analyze` clean.
- [x] Add `extension PaletteContext on BuildContext { DpdPalette get palette }` in same file.
  → verify: `flutter analyze` clean.
- [x] Create `lib/theme/dpd_scheme.dart`: `enum DpdScheme { purana, kasaya, talapanna }` + `palettesFor(DpdScheme)` registry.
  → verify: `flutter analyze` clean.
- [x] Create `lib/theme/schemes/purana.dart` using current HSL values.
  → verify: visual diff — app looks pixel-identical.
- [x] Create `lib/theme/schemes/kasaya.dart` with light + dark Kimbie-inspired palettes.
  → verify: `flutter analyze` clean.
- [x] Create `lib/theme/schemes/talapanna.dart` with light + dark muted palm-leaf palettes.
  → verify: `flutter analyze` clean.

### Phase 2 — Settings model + persistence
- [x] Add `DpdScheme colourScheme` field to `Settings` (default `DpdScheme.purana`) with `copyWith`, `==`, `hashCode` updates.
  → verify: `flutter analyze` clean.
- [x] Add load + setter (`setColourScheme`, persistence key `colour_scheme`).
  → verify: `flutter analyze` clean.

### Phase 3 — Wire palette into MaterialApp
- [x] Update `lib/app.dart`: read `settings.colourScheme`, resolve to light+dark `DpdPalette`, inject as `ThemeData.extensions`, derive `ColorScheme` from palette.
  → verify: app builds and runs; scheme changes update framework chrome.
- [x] Make `_switchTheme` palette-aware.
  → verify: switch widgets recolour when scheme changes.

### Phase 4 — Migrate call sites to `context.palette`
- [x] `lib/screens/` (search_screen, root_screen, download_screen).
  → verify: rg returns nothing for colour refs.
- [x] `lib/widgets/` group A: tables and sections.
  → verify: rg clean.
- [x] `lib/widgets/` group B: cards & entry content.
  → verify: rg clean.
- [x] `lib/widgets/` group C: sheets, popups, panels, dialogs.
  → verify: rg clean.
- [x] Whole-tree sweep: zero matches.
  → verify: `flutter analyze` clean.
- [x] Delete unreferenced colour getters from `lib/theme/dpd_colors.dart`.
  → verify: `flutter analyze` clean.

### Phase 5 — Settings UI selector
- [x] Add three-way scheme selector next to brightness toggle in `lib/widgets/settings_panel.dart`.
  → verify: tapping each chip recolours app instantly; persists across hot-restart.

### Phase 6 — Final verification
- [ ] `flutter analyze` clean.
- [ ] Manual: search → entry → grammar → families → inflections; switch 3 schemes × 2 brightnesses.
  → verify: user confirms via Section 4.1 STOP.
