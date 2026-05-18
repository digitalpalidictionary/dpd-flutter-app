# Plan: Bold rendering in Summary for meaning_1

## Architecture Decisions
- Add `meaningHasBold: bool` to `SummaryEntry` (default false) — explicit flag matching user's "not for meaning_2" requirement
- Inline `_parseBoldSpans` in summary_section.dart — avoids creating a shared utils file for a 10-line function; follows the same pattern already in entry_content.dart

## Phase 1: Implement bold rendering in summary

- [x] Add `meaningHasBold` field to `SummaryEntry` (default false)
  → verify: flutter analyze — no issues

- [x] In `_buildHeadwordSummaryMeaning`, return `(String, bool)` tuple; set `meaningHasBold: true` in headword entry when meaning_1 is used
  → verify: flutter analyze — no issues

- [x] In `summary_section.dart`, add `_parseBoldSpans` helper; use `meaningSpans()` local function in `_SummaryRow` for both render paths
  → verify: flutter analyze — no issues ✓
