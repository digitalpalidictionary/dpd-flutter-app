# Other Dictionaries in the Summary

## Overview

When a search word also has an exact match in an external dictionary (Cone, CPD, DPPN, MW, PEU, BHS, Apte, WordNet, Nyanatiloka), the summary at the top of the results does not mention it. The user has to scroll blind to find out whether Cone has something. Add one summary row per external dictionary with an exact hit, so it can be tapped to jump straight to that dictionary's card.

## What it should do

- One summary row per external dictionary that has an **exact** result. Not one row per matched entry — all of a dictionary's entries render inside a single card, so a single card is the only reachable jump target.
- Row uses the same format as every other summary row: matched word in bold, then the source label.
  ```
  dhamma  Cone.
  dhamma  PEU.
  Dhamma  DPPN.
  ```
- The source label is a short one-word dictionary abbreviation (`Cone`, `CPD`, `DPPN`, `MW`, `PEU`, `BHS`, `Apte`, `WordNet`, `Nyanatiloka`) — **not** `dict_meta.name`, which carries CC attribution text and runs up to 58 characters.
- The word shown is the dictionary's own spelling of it, so DPPN's capitalised proper names read as `Dhamma`, matching what the card below says.
- Tapping the row scrolls to that dictionary's card.
- The whole summary is ordered by the dictionary order in Settings, interleaved — DPD sources and external dictionaries together in one sequence, mirroring the order the results themselves are rendered in.
- A Settings toggle controls it, placed directly below "Construction in summary". Default on.

## Constraints

- Only the exact tier. Partial and fuzzy dictionary hits stay out of the summary — they live below their tier dividers and the summary is a first-tier index.
- Native Flutter widgets, existing `SummaryEntry` model and `_SummaryRow` layout. No new row widget.
- Theme colours only.
- Dictionaries disabled in Settings must not appear (already handled — disabled dictionaries never reach the results).
- An unknown future dictionary id must still render something sensible rather than crash or show a blank label.

## Design notes from research

**Ordering is already solved upstream.** `presentDictSearchResults` walks `visibility.order` and emits dictionaries in Settings order, so the summary inherits correct ordering for free.

**The actual blocker.** External dictionary cards are the only tier-1 items added to the results list *without* registering a scroll target — they call `tier1.add` rather than `addTier1`. Without fixing that, a summary row for Cone would render but tapping it would do nothing. This is the substance of the change.

**Interleaving is a simplification, not added complexity.** `buildSummaryEntries` currently hardcodes headwords → roots → secondary, duplicating ordering logic that `SplitResultsList` already does properly by looping over the Settings order. Rewriting the builder as the same loop removes the duplication and makes the summary agree with the page by construction.

**Known consequence of interleaving:** DPD summary rows also become Settings-ordered, so a user who has dragged roots above headwords will now see roots first in the summary too. That is the intended reading of "ordered by the dictionary order in settings".

**Size is not a concern.** Measured against the real 9-dictionary export (~640k entries): for any given word, 92% match exactly one external dictionary, 8% match two, and the worst case across the entire database is 8. The summary grows by one to three rows in practice.

**Known cosmetic wart, accepted:** the dictionary queries resolve later than the headword query, so the summary renders and then grows, pushing the first entry down. The page body already reflows this way today; this makes it slightly more visible. Not fixed here.

**Jump cost — measured, and it is a non-issue.** The concern was that tapping a summary row jumps to a dictionary card whose HTML then parses synchronously on the tap frame, freezing right after touch. Measured with a throwaway harness (since removed) against real exported HTML, median of 3 reps after a warmup pump:

| card | bytes | prepare | build | total |
|---|---|---|---|---|
| Cone `citta` | 76 KB | 20ms | 25ms | 45ms |
| Cone `dhamma` | 135 KB | 19ms | 22ms | 41ms |
| CPD `kamma` | 113 KB | 0ms | 12ms | 12ms |
| DPPN `buddha` | 35 KB | 0ms | 18ms | 18ms |
| PEU `dhamma` | 2 KB | 0ms | 14ms | 14ms |

Worst case ~2.5 dropped frames. Two things this corrected:

1. An unwarmed first measurement read 569ms for Cone `dhamma`. That was first-pump framework warmup, not HTML — it vanished with a warmup pump. Any cost model built on that number is wrong.
2. **Byte size does not predict render cost.** CPD `kamma` at 113 KB costs 12ms; Cone `citta` at 76 KB costs 45ms. Cone is expensive because its pre-processing does a full DOM parse and its span-heavy markup hammers the style callback. Do not rank dictionary cards by size.

Caveat: host desktop, debug JIT, load ~4. Debug is slower than release, a phone CPU is slower than this desktop; the two pull opposite ways, so no device figure is claimed. Magnitude is tens of ms, an order of magnitude below where it would matter. Confirmed on device during manual verification.

**Separate pre-existing inefficiency, deliberately out of scope:** Cone's ~20ms DOM parse runs inside the card's `build`, so it re-parses on every rebuild, including every time the card scrolls back into view. Memoizing it would help scrolling app-wide. Own thread.

## How we'll know it's done

- Searching `dhamma` shows Cone, PEU, DPPN and Nyanatiloka rows in the summary; tapping each lands on the right card.
- Searching `citta` (7 dictionaries) shows all 7 rows, in Settings order.
- Reordering dictionaries in Settings reorders the summary rows to match.
- Disabling Cone in Settings removes its summary row.
- Toggling the new Settings option off removes all external dictionary rows and leaves the DPD rows untouched.
- Searching a word with no external dictionary hits leaves the summary exactly as it is today.

## What's not included

- No partial or fuzzy dictionary rows in the summary.
- No entry counts or definition snippets on the rows.
- No change to `dict_meta` or the exporter in `../dpd-db/` — the abbreviations live in the app.
- No fix for the summary reflow after first paint.
