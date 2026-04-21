# Plan

## Phase 1 — Fix arrow alignment
- [ ] Restructure headword branch in `_SummaryRow.build` (lib/widgets/summary_section.dart)
      so the lemma heading is its own row (no arrow) and the suffix+type+meaning
      line is a Row with the ► arrow at the end.
      → verify: `flutter analyze lib/widgets/summary_section.dart` passes

## Phase 2 — Manual verification
- [ ] User tests with a multi-item headword (e.g. "kamma") and confirms arrow
      placement.
      → verify: visual check
