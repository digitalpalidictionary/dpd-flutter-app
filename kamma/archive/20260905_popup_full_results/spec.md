# Spec: Full search results in the word popup

## Request

> "At the moment when pop-up is selected in settings, only DPD results appear in the pop-up.
> I want the same results (apart from the summary) to appear in the popup."

The popup should show everything the full search results page shows — roots, deconstructor,
grammar, EPD, variants, spelling, "see also", abbreviations, external dictionaries, and the
partial/fuzzy tiers — with the summary section suppressed.

## Viability: yes, and cheaply

Verified by reading the code, 2026-09-05:

1. `SplitResultsList` (`lib/widgets/split_results_list.dart`) is a plain `StatefulWidget`
   with no dependency on the search screen. It takes data lists + display settings and
   renders the whole result stack. It already has a `showSummary` flag, so suppressing the
   summary is a parameter, not a code change.
2. Every provider it is fed from is an `autoDispose.family` keyed by the query string
   (`exactResultsProvider`, `partialResultsProvider`, `fuzzyResultsProvider`,
   `rootResultsProvider`, `secondaryResultsProvider`, `dictResultsProvider`,
   `summaryEntriesProvider`). The popup can watch them for its own word without touching
   `searchQueryProvider`, exactly as it already does for exact results.
3. The only thing standing between the popup and the full stack is ~90 lines of assembly
   logic that currently lives inline in `SearchScreen._buildBody` — dedup of partial/fuzzy
   against exact, the `showPartialResults` / `showFuzzyResults` settings gates, the loading
   and error states, and the empty-results verdict.
4. Its scrolling widget is a `ScrollablePositionedList`, which works inside the popup's
   `Expanded` just as the current `ListView` does.

So the work is an extraction, not new rendering code.

## Current behaviour (verified)

`showWordPopup` (`lib/widgets/word_popup.dart`) watches `exactResultsProvider(_word)` only,
and renders a bare `ListView` of `InlineEntryCard`s inside a `TapSearchWrapper`. Anything
that is not a DPD headword is simply absent — including the deconstructor, which is the most
likely thing a user taps a compound for.

`SearchScreen._buildBody` (`lib/screens/search_screen.dart`, ~lines 907–1022) does the
assembly and hands the result to `SplitResultsList` wrapped in `ContentTextScale` +
`TapSearchWrapper`.

## What to build

Extract the assembly into one shared widget and use it in both places.

**New:** `lib/widgets/search_results_body.dart` — a `ConsumerWidget` taking:

- `query` — the word to look up
- `showSummary` — screen passes the setting, popup passes `false`
- `suggestionsVisible` — screen passes its dropdown state, popup passes `false`
  (this only gates whether the "no results" verdict is withheld mid-typing)

It reproduces, unchanged, the existing logic: loading spinner while exact is loading and
empty, error text on exact error, dedup of partial against exact and fuzzy against both, the
`showPartialResults` / `showFuzzyResults` gates, the empty-state branch
(`EmptyPrompt` / `NoResultsWithSuggestions`), and the final `SplitResultsList`.

**Changed:** `SearchScreen._buildBody` keeps only what is screen-specific — the
empty-query home/prompt branch and the search-timing instrumentation — and delegates the
rest to the new widget.

**Changed:** `word_popup.dart` replaces its exact-only `ListView` with the new widget,
`showSummary: false`, still inside its own `TapSearchWrapper` so a tap swaps the popup's word
rather than opening a second sheet.

The `TapSearchWrapper` stays *outside* the extracted widget in both callers — the screen and
the popup need different tap behaviour, and nesting two would double-handle taps.

## Explicitly out of scope

- The summary section in the popup — the user asked for it to stay out.
- Search timing instrumentation in the popup.
- `ContentTextScale` in the popup. The popup does not currently apply the user's content
  text size and this thread does not change that; it is a pre-existing inconsistency worth a
  separate decision, flagged here rather than silently fixed.
- Any change to result ordering, ranking, or the dictionary visibility/order settings.

## Assumptions

1. "The same results apart from the summary" means the full stack including partial and
   fuzzy tiers, honouring the user's existing per-tier and per-dictionary settings. The
   popup shows what the page would show for that word.
2. `DisplayMode` (compact/full) applies in the popup exactly as on the page.
3. The popup's 70%-of-screen height stays as is; the longer content simply scrolls.

## Risks

- **Cost of a tap.** The popup will now fire five more queries per tapped word, including
  the external-dictionary search. On a slow device a tap could feel heavier than it does
  today. Mitigation: the providers are the same ones the page uses and are `autoDispose`
  families, so a re-tap of a recent word is cached; measure on device before deciding
  anything further.
- **Behaviour parity regression on the search screen.** The extraction must preserve the
  screen's behaviour byte-for-byte. Verified by reading the diff and by manual testing of
  the normal search path, not just the popup.

## Confidence: 8/10

The extraction itself is mechanical and the enabling facts are verified. The point deducted
is for the tap-latency question, which can only be answered on a real device.
