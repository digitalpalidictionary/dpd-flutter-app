# Transliteration Input Support — Plan

## Phase 1: Package & Core Utility
- [x] Add `indic_transliteration_dart` to pubspec.yaml (pure Dart, no FFI — avoids Android 15+ 16 KB ELF alignment failure from `inditrans`)
- [x] Create `lib/utils/transliteration.dart` — `initTransliteration()` (sync) + `toRoman()` with auto-detect via `itr.detect()`
- [x] Add try-catch in `toRoman()` for safe fallback on package errors
- [x] Call `initTransliteration()` at app startup in `main.dart`

## Phase 2: Wire Input
- [x] `_onChanged` in `search_screen.dart`:
  - Apply `velthuis()` live — rewrites field only for Velthuis sequences
  - Apply `toRoman()` to produce the DB query (debounced search + autocomplete)
  - Field is never written by `toRoman()`
- [x] `_onSearch` in `search_screen.dart`:
  - Apply `toRoman(_controller.text.trim())` for DB query
  - Field is never written
- [x] `ref.listen(searchQueryProvider)` listener updated:
  - Skips syncing to controller if `toRoman(_controller.text) == next`
  - Preserves original script in field when debounce/search fires
  - Still syncs for external sources (double-tap word search, intent launch)
- [x] Remove `_toSearchQuery` helper and all InputScript/`velthuis` references from inditrans era
- [x] Remove InputScript from `settings_provider.dart`
- [x] Remove InputScript dropdown from `settings_panel.dart`

## Phase 3: Verification
- [x] `flutter analyze` on all changed files — no issues
- [x] spec.md and plan.md in sync with final implementation
