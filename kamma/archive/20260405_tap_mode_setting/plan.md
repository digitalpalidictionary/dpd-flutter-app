# Plan: Single-tap word search with settings toggle

## Phase 1 — Settings plumbing
- [x] Add `TapMode` enum (`singleTap`, `doubleTap`) to `settings_provider.dart`
- [x] Add `tapMode` field to `Settings` class (default: `TapMode.singleTap`)
- [x] Add `copyWith`, `==`, `hashCode` support for the new field
- [x] Add `_load` / `setTapMode` to `SettingsNotifier`
- [x] Add "Word search tap" toggle to `settings_panel.dart` (Single / Double)
- [x] Verify: flutter analyze passes, existing tests unaffected

## Phase 2 — Tap search wrapper
- [x] Rename `DoubleTapSearchWrapper` → `TapSearchWrapper` (file + class + all imports)
- [x] Read `tapMode` from settings inside the wrapper
- [x] Single-tap mode: trigger search on every pointer-down + selection (no double-tap timing)
- [x] Double-tap mode: keep existing 500ms timing logic
- [x] Update all 4 call-sites (search_screen, entry_screen, root_screen, inflection_table)

## Phase 3 — Verification
- [x] `flutter analyze` clean (only pre-existing info)
- [x] `flutter test` — no new failures (11 pre-existing failures unchanged)
- [ ] Manual test by user
