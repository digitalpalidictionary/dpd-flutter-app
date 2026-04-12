# Full Repo Transliterator Migration - Plan

## Phase 1: Thread Setup And Baseline
- [x] Create a dedicated branch for this significant change from current HEAD.
- [x] Re-read the current transliteration/search touchpoints:
  - `lib/utils/transliteration.dart`
  - `lib/screens/search_screen.dart`
  - `lib/main.dart`
  - `test/utils/transliteration_test.dart`
  - `kamma/tech.md`
  - `pubspec.yaml`
- [x] Update `kamma/tech.md` with a dated note that the app is moving from `indic_transliteration_dart` to the full transliterator imported from `../tipitaka-pali-reader`, while preserving the existing search-field UX and Roman no-op fast path.
- [x] Verification task:
  - confirm branch exists
  - confirm `kamma/tech.md` is updated before code changes begin

## Phase 2: Import The Full Transliterator
- [x] Import the full transliterator code needed from `../tipitaka-pali-reader` into local utilities under `lib/utils/`.
- [x] Preserve the imported structure clearly enough that the search adapter can use:
  - script detection
  - Roman passthrough
  - script-to-Roman conversion
  - Myanmar-specific handling
  - the general multi-script converter
- [x] Keep imports and local naming clean so the app uses the imported code without dragging in unrelated UI code from the sibling repo.
- [x] Verification task:
  - confirm the imported transliterator files compile within this repo

## Phase 3: Replace The App Transliteration Adapter
- [x] Refactor `lib/utils/transliteration.dart` to wrap the imported transliterator for this app’s search flow.
- [x] Make the transliteration adapter behavior explicit:
  - empty input returns unchanged
  - Roman input returns unchanged immediately
  - non-Roman input uses imported detection plus script-to-Roman conversion
- [x] Remove obsolete initialization logic if the new transliteration path does not require package setup.
- [x] Update `lib/main.dart` to match the new transliteration utility contract.
- [x] If the old dependency is no longer needed, remove `indic_transliteration_dart` from `pubspec.yaml` and refresh dependencies.
- [x] Verification task:
  - confirm representative Roman, Sinhala, Devanagari, Thai, and Myanmar inputs normalize as expected through `lib/utils/transliteration.dart`

## Phase 4: Keep Search UX Intact
- [x] Re-check `lib/screens/search_screen.dart` and keep the existing behavior boundaries unchanged:
  - `velthuis(raw)` may rewrite `_controller`
  - transliteration only produces the lookup query
  - `_suppressProviderSync` still prevents local query sync from clobbering the typed script
- [x] Confirm debounced search and explicit search both use the same updated `toRoman(...)` path.
- [x] Verification task:
  - confirm the visible field behavior remains unchanged apart from existing Velthuis conversion

## Phase 5: Tests And Verification
- [x] Expand `test/utils/transliteration_test.dart` to cover:
  - Roman no-op behavior
  - IAST no-op behavior
  - representative script-to-Roman conversions using the imported transliterator
  - Velthuis remains separate behavior
  - cross-script round-trips for representative words including conjunct + `e/o` cases
- [x] Run relevant automated verification for the changed area.
- [x] Fix any failing checks up to two attempts per verification step, documenting any remaining limitation in `plan.md` if needed.
- [x] Verification task:
  - confirm tests and final code match the actual implemented behavior
