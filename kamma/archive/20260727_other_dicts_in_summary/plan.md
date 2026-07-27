# Plan: Other Dictionaries in the Summary

## Phase 1: Make dictionary cards reachable

- [x] `lib/widgets/split_results_list.dart` — register a scroll target for the exact-tier external dictionary card
  - [x] Change the `default:` branch's `tier1.add(...)` for `exactResult` to `addTier1(..., 'dict_$sourceId')`
  - [x] Leave the partial and fuzzy branches alone — they are tier 2/3 and have no summary rows
  - [x] Verify: `flutter analyze`

## Phase 2: Short dictionary names

- [x] `lib/providers/dict_provider.dart` — add `dictShortName(String dictId)`
  - [x] Explicit map for the nine shipped dictionaries: cone→Cone, cpd→CPD, dppn→DPPN, mw→MW, peu→PEU, bhs→BHS, apte→Apte, wordnet→WordNet, nyanatiloka→Nyanatiloka
  - [x] Fallback for an unknown id: capitalise the first letter
  - [x] Verify: unit test covering each known id plus an unknown one

## Phase 3: Settings toggle

- [x] `lib/providers/settings_provider.dart` — add `showOtherDictsInSummary`, default `true`
  - [x] Field, constructor param, `copyWith`, `==`, `hashCode`
  - [x] Load from pref key `show_other_dicts_in_summary`
  - [x] `setShowOtherDictsInSummary(bool)` setter following the existing pattern
- [x] `lib/widgets/settings_panel.dart` — add the tile directly after "Construction in summary"
  - [x] Title "Other dictionaries in summary", Hide/Show `CompactSegmented<bool>`
  - [x] `_otherDictsInSummaryTopic()` help topic
  - [x] Verify: `flutter analyze`

## Phase 4: Interleave the summary by Settings order

- [x] `lib/providers/summary_provider.dart` — rewrite `buildSummaryEntries` as a single loop over the Settings order
  - [x] Add named params `dictExact` (default `const []`) and `order` (nullable)
  - [x] When `order` is null, fall back to the `kDpdSources` id order so existing tests keep their current expectations
  - [x] Skip `dpd_summary` — it positions the summary itself, it is not a row source
  - [x] For each id in order: emit headword rows, root rows, the matching secondary row, or the matching external dictionary row
  - [x] Extract the existing per-result-type row construction unchanged; only the iteration changes
  - [x] Check no existing test asserts an arrival-order-dependent sequence of two or more secondary results — the loop now orders them by Settings order instead. Confirmed: no test does; full suite still passes.
- [x] Add `SummaryEntryType.dict` to `lib/models/summary_entry.dart`
- [x] Build the dictionary row: label = `entries.first.word`, typeLabel = `'${dictShortName(dictId)}.'`, meaning = `''`, targetId = `'dict_$dictId'`
- [x] `summaryEntriesProvider` — watch `dictResultsProvider(query)` for the exact tier, `dictVisibilityProvider.order`, and the new setting
  - [x] Pass an empty dictionary list when the setting is off
- [x] Verify: `flutter analyze`; existing summary tests pass

## Phase 5: Tests

- [x] `test/providers/summary_provider_test.dart`
  - [x] One dictionary with one exact entry produces one row with the right label, short name and target id
  - [x] A dictionary with several exact entries still produces exactly one row
  - [x] Rows follow the supplied Settings order, interleaved with DPD rows
  - [x] An empty dictionary list produces the same output as today
  - [x] (added) An unknown dictionary id still renders a sensible short name
- [x] Verify: full `flutter test` suite

## Phase 6: Handoff

- [x] Run `flutter analyze` and the full `flutter test` suite clean — analyze: 0 issues in touched files (51 pre-existing infos elsewhere, unrelated); test: 346/346 passed
- [x] Manual verification on Android:
  - [x] `dhamma` → Cone, PEU, DPPN, Nyanatiloka rows; each taps to the right card
  - [x] `citta` → 7 dictionary rows in Settings order
  - [x] Reorder dictionaries in Settings → summary order follows
  - [x] Disable Cone → its row disappears
  - [x] Toggle the new setting off → dictionary rows gone, DPD rows unchanged
  - [x] A word with no external hits → summary unchanged
  - [x] Tap the Cone row on `dhamma` and on `citta` — confirmed on device. There is a perceptible delay on jump but user judged it manageable, not a blocker.
- [x] Await explicit user confirmation before any commit — confirmed, "it all works, everything tested"
