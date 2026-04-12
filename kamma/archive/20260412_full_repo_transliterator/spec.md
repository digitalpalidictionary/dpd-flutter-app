# Full Repo Transliterator Migration

## Overview
Replace the current search-input transliteration stack in `dpd-flutter-app` with the transliterator from the sibling repository `../tipitaka-pali-reader`.

Relevant current app context:
- `lib/utils/transliteration.dart` currently uses `indic_transliteration_dart`.
- `lib/screens/search_screen.dart` already has the correct UX boundary:
  - Velthuis rewrites the visible field live.
  - Query normalization happens separately via `toRoman(...)`.
  - `_suppressProviderSync` prevents provider-to-controller sync from overwriting the user's typed script during local search.
- `lib/main.dart` currently initializes the existing transliteration package at startup.
- `test/utils/transliteration_test.dart` currently covers only a small subset of transliteration behavior.

Relevant sibling repo context:
- `../tipitaka-pali-reader/lib/utils/script_detector.dart`
- `../tipitaka-pali-reader/lib/utils/pali_script.dart`
- `../tipitaka-pali-reader/lib/utils/pali_script_converter.dart`
- `../tipitaka-pali-reader/lib/utils/mm_pali.dart`
- `../tipitaka-pali-reader/lib/utils/roman_to_sinhala.dart`

Permission context for this thread:
- The author has given permission to use the transliterator code.
- The project is non-commercial.
- The transliterator should therefore be imported in full for this thread.

Benchmark context gathered before implementation:
- The sibling repo transliterator converts representative non-Roman samples to Roman correctly and in low microseconds per operation.
- The current app path does not correctly convert several tested non-Roman samples.
- Roman input must remain a strict fast no-op: if the text is already Roman, return it unchanged immediately.

## What it should do
1. Use the full sibling repo transliterator stack for script-to-Roman lookup normalization.
2. Treat already-Roman input as already done:
   - detect Roman
   - return it unchanged
   - do not run unnecessary conversion work
3. Keep the current search bar UX unchanged:
   - Velthuis still rewrites the visible field live
   - non-Velthuis transliteration never rewrites the field
   - `_suppressProviderSync` still preserves the typed script during local search
4. Normalize both debounced search and explicit search through the same transliteration path.
5. Support the sibling repo’s script detection/conversion coverage in the search normalization flow, including Sinhala and the other supported scripts brought in by the imported converter.
6. Remove obsolete dependency/setup code from the old transliteration package if it is no longer needed.

## Constraints
- The search field must never be overwritten by transliteration or query normalization except for Velthuis live conversion.
- Keep the implementation tightly scoped to search-input normalization and its tests.
- Roman input is already Roman; it must be returned immediately.
- This is a significant change, so create a dedicated branch first.
- Update `kamma/tech.md` before implementation because the transliteration toolchain is changing.

## How we'll know it's done
- Roman and IAST input return unchanged through the transliteration adapter.
- Representative non-Roman script inputs convert to Roman correctly for lookup.
- Debounced search and explicit search both use the new transliteration path.
- The visible search field still preserves the user’s script except for Velthuis live conversion.
- Tests cover Roman no-op behavior and representative script-to-Roman cases from the imported converter.
- Relevant automated verification passes.

## What's not included
- Display transliteration of entry content.
- Search UI redesign.
- Database or schema changes.
- Behavioral changes outside the search/transliteration path.
