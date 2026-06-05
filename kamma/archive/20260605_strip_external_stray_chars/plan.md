# Plan: Strip stray characters from external searches

## Architecture Decisions
- Flip blacklist → allowlist in one place (`_clean`); all external entry
  points share it. Simplest, most future-proof.
- Use Unicode property classes (\p{L}\p{M}\p{N}) for script-agnostic
  coverage instead of enumerating script ranges.
- Keep URL stripping as a separate first pass (relies on : and / the
  allowlist would otherwise remove).
- Seed the controller in a post-frame callback (not directly in initState)
  because mutating `searchBarTextProvider` during initState/build crashes
  Riverpod (red screen on cold start).

## Phase 1: Allowlist cleaning [x]
- [x] Rewrite `_clean()` in `lib/services/intent_service.dart`: strip URL,
      normalise curly apostrophes, strip disallowed (allowlist), trim edge
      ' - . and whitespace. Remove `_quotePattern`/`_bracketPattern`.
      → verify: `flutter analyze` clean. PASS.
- [x] Add tests to `test/services/intent_service_test.dart` (markdown,
      internal apostrophe kept + wrapping trimmed, internal hyphen kept,
      Devanagari).
      → verify: `flutter test test/services/intent_service_test.dart`. PASS (13).

## Phase 2: Show external word in search bar [x]
- [x] Add `initState` post-frame seed in `lib/screens/search_screen.dart`
      mirroring the searchQueryProvider listener's display logic, guarded by
      `_controller.text.isNotEmpty` and `mounted`.
      → verify: cold-start share shows word in editable bar, no crash.
        Confirmed by user on device.
