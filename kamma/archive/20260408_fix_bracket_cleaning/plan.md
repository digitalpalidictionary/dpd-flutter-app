# Plan: Fix bracket cleaning in tap-to-search

## Phase 1: Fix _cleanPali
- [x] Add `[`, `]`, `(`, `)`, `{`, `}` to the leading and trailing strip
      regexes in `_cleanPali` (tap_search_wrapper.dart:157-159)
- [x] Verify fix handles nested cases like `[√bhid]` → `√bhid`

## Phase 2: Verification
- [x] User tests on device
