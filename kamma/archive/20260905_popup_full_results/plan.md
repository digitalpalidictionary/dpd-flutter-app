# Plan: Full search results in the word popup

Spec: `spec.md`

## Baseline

- [x] **B1 — Record the pre-existing state**
  Run `flutter analyze` and `flutter test` and note any failures that already exist on a
  clean tree, so nothing pre-existing gets blamed on this thread.
  → verify: both commands run; failures (if any) recorded here.
  **Result (2026-09-05):** `flutter analyze` — 0 errors, 51 pre-existing infos, all in
  `lib/utils/pali_transliterator/*`, `lib/utils/search_timing.dart` and other files this
  thread does not touch. `flutter test` — all 384 tests passed. Clean baseline.

## Phase 1 — Extract the shared results body

- [x] **T1 — Create the shared widget**
  Add `lib/widgets/search_results_body.dart` with a `ConsumerWidget` taking `query`,
  `showSummary`, `suggestionsVisible`. Move the assembly logic out of
  `SearchScreen._buildBody` verbatim: provider watches, partial/fuzzy dedup, the
  `showPartialResults` / `showFuzzyResults` gates, loading and error branches, the
  empty-results branch, and the `SplitResultsList` construction.
  No behaviour changes, no refactoring beyond the move.
  → verify: `flutter analyze` clean on the new file.

- [x] **T2 — Point the search screen at it**
  Reduce `SearchScreen._buildBody` to the empty-query branch plus the search-timing
  instrumentation, delegating everything else to `SearchResultsBody` with the settings-driven
  `showSummary` and the screen's `_suggestionsVisible`. Leave `ContentTextScale` and
  `TapSearchWrapper` where they are, outside the new widget.
  → verify: `flutter analyze` clean; search a word on device and confirm the results page is
  visually and behaviourally identical — summary, tiers, dividers, scroll-to-entry from the
  summary, compact mode, dictionary order.

## Phase 2 — Use it in the popup

- [x] **T3 — Swap the popup body**
  Replace the exact-only `ListView` in `word_popup.dart` with `SearchResultsBody(query: _word,
  showSummary: false, suggestionsVisible: false)`, keeping the popup's own
  `TapSearchWrapper` around it so a tap swaps the sheet's word. Remove the popup's now-dead
  `exactResultsProvider` watch, loading/error/empty handling, and `InlineEntryCard` import if
  unused.
  → verify: `flutter analyze` clean.

- [x] **T4 — Manual verification on device**
  With "Word lookup: Popup" set, tap words and confirm:
  - roots, deconstructor, grammar, EPD, variants, spelling, see-also and external
    dictionaries all appear;
  - the summary section does **not** appear;
  - partial and fuzzy tiers appear with their dividers and respect the settings toggles;
  - a tap inside the sheet swaps its word rather than opening a second sheet;
  - "Full search" still opens the full page and records history correctly;
  - a word with no results shows the no-results state, not a blank sheet;
  - the tap still feels responsive — note any lag, since the popup now runs five more
    queries per tap.
  → verify: user confirms on Android.
  **Result (2026-09-05):** user confirmed on device — all sections present, summary absent,
  and **no tangible lag** from the extra queries per tap. The spec's main risk is closed.

## Phase 3 — Close out

- [x] **T5 — Full smoke pass**
  Run `flutter analyze` and the full `flutter test` suite. Compare against the B1 baseline;
  fix anything this thread caused.
  → verify: no new failures.

- [x] **T6 — Review**
  Run `/kamma:3-review` plus a CodeRabbit pass, with particular attention to whether the
  extraction preserved the search screen's behaviour exactly.
  **Result (2026-09-05):** CodeRabbit — 0 findings. Independent agent review — 3 minor, 2 nits,
  no blocking or major; all five fixed and re-verified. See `review.md`. It did catch a real
  parity break the extraction introduced: the info view unmounted the result subscriptions,
  so closing an info page showed a spinner instead of the results.

**T5 result (2026-09-05):** `flutter analyze` — 0 errors, same 51 pre-existing infos as the
baseline. `flutter test` — all 384 passed. No new failures.

## Notes

- `dart format` was NOT run over `search_screen.dart`: the file was not formatter-clean
  before this thread, so formatting it reflowed a dozen unrelated lines and buried the real
  diff. The hand-written replacement follows the surrounding style. The new
  `search_results_body.dart` is formatted.
- Deviation from the spec (recorded per the drift gate): the extracted widget takes a
  `recordTimings` flag rather than leaving the timing instrumentation behind in the screen.
  The timing block has to sit in the render path, so a flag was the only way to move the
  assembly wholesale while keeping the popup out of the timing data.
- Behaviour change in the popup's empty state: it now shows the shared
  `NoResultsWithSuggestions` (with closest matches) instead of its own plain "No results"
  line. Verified those suggestions are inert text, so the popup's own tap handling applies
  to them — tapping one swaps the sheet's word rather than disturbing the main search.

- No tests are added: this is UI-only, and the project forbids UI tests.
- Wait for explicit Android test confirmation before committing.
