# Plan

## Phase 1: Align summary data with the real headword definition
- [x] Inspect the current summary-building path in `lib/providers/summary_provider.dart` and the current headword summary presentation in `lib/widgets/summary_section.dart`.
- [x] Update headword summary data so it carries the fields needed to mirror the real entry summary content order more closely.
- [x] Reuse the same meaning-selection rules already used by the full entry summary so the top summary and full result do not disagree.
- [x] Verify Phase 1:
  - [x] Run targeted analysis on the summary provider and related model files.

## Phase 2: Make headword summary rows meaning-first and multiline
- [x] Update `lib/widgets/summary_section.dart` so headword summary entries render `lemma_1`, `pos`, main meaning, and `[construction_summary]` in the agreed order.
- [x] Remove the forced one-line truncation for headword summary entries and allow wrapping on smaller screens.
- [x] Keep summary taps scrolling to the matching result and avoid turning summary rows into duplicate cards.
- [x] Keep non-headword summary entries visually coherent without broad redesign.
- [x] Verify Phase 2:
  - [x] Run targeted analysis on the updated search/summary UI files.

## Phase 3: Verify behavior and edge cases
- [x] Add or update focused non-UI tests for headword summary data formatting and meaning fallback rules.
- [x] Check that headword summaries still render sensibly when optional fields like `pos` or `construction_summary` are missing.
- [x] Check that long meanings wrap cleanly and do not break row layout.
- [x] Confirm compact mode behavior is unchanged by the summary updates.
- [x] Verify Phase 3:
  - [x] Run the most relevant local verification command(s) for the changed files and confirm they pass.

## Phase 4: Thread bookkeeping and final verification
- [x] Create the Kamma thread files under `kamma/threads/<thread_id>/` after approval.
- [x] Implement the approved changes and keep `plan.md` in sync as items are completed.
- [x] Run a final local verification pass.
- [x] Prepare concrete manual test steps for the summary-first search flow.
- [x] Verify Phase 4:
  - [x] Confirm the thread files reflect the final state before asking for manual testing.
