# Plan: s.4nt.org Link in Sutta Info

## Phase 1: Port the link algorithm

- [x] `lib/database/sutta_info_extensions.dart`
  - [x] Add `_s4ntKnBooks` constant set (20 KN book codes)
  - [x] Add `_s4ntAnchorOverrides` constant map (45 entries, copied verbatim from `_S4NT_ANCHOR_OVERRIDES` in `../dpd-db/db/models.py`)
  - [x] Add `String? get s4ntLink` getter following the ported algorithm, reusing `_scBookCode`
  - [x] Verify: `flutter analyze`

## Phase 2: Wire into the UI

- [x] `lib/widgets/sutta_info_section.dart` — add `_linkRow(context, 's.4nt.org', s.s4ntLink)` to the "Websites using Sutta Central" table, after the SC Voice row
  - [x] Verify: `flutter analyze`

## Phase 3: Tests

- [x] `test/database/sutta_info_extensions_test.dart` — cover:
  - [x] DN/MN → exact page, no fragment
  - [x] SN/AN bare nipāta code → no fragment
  - [x] SN/AN sutta code with default fragment
  - [x] SN/AN sutta code with an override fragment (from the map)
  - [x] KN book code with default and overridden fragment
  - [x] Unsupported book code → null
  - [x] No scCode → null
  - [x] Verify: `flutter test`
- [x] (added, not a permanent test) full-database parity check: computed `s4ntLink` for every one of the 4678 sc_codes in `dpd.db` against a reimplementation of the Python algorithm run over the same codes — 0 mismatches. Confirms the override map and algorithm are byte-for-byte correct against real data, not just hand-picked examples. Script removed after verification.

## Phase 4: Handoff

- [x] `flutter analyze` and `flutter test` clean (353/353 tests passed)
- [x] Manual verification (Linux desktop, via `just linux-run`) — user confirmed 2026-07-31: works
