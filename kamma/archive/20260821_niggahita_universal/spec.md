# Niggahīta setting applies everywhere

## Overview

The app has a niggahīta display setting (Settings → `ṃ` / `ṁ`). Choosing `ṁ`
currently changes only four widgets. Everywhere else — most visibly the
autocomplete dropdown under the search bar — still shows `ṃ`.

The user's report: *"When you have chosen niggahīta ṁ in settings, in the search
bar it still shows ṃ for all the suggested words. Universally use whatever the
settings has chosen."*

## Current behaviour (verified by reading the code)

- The setting lives in `lib/providers/settings_provider.dart` as
  `NiggahitaMode.dot` / `NiggahitaMode.circle`, persisted under the
  `niggahita_mode` preference key.
- The conversion itself is `filterNiggahita()` in `lib/utils/text_filters.dart`
  — a pure `ṃ→ṁ` / `Ṃ→Ṁ` string replace.
- Only four widgets call it today: `inline_entry_card.dart`,
  `grammar_table.dart`, `accordion_card.dart`, `entry_content.dart`. Each
  repeats the same four lines, including the brittle bridge
  `NiggahitaFilterMode.values[niggahitaMode.index]`, which silently depends on
  two unrelated enums keeping the same member order.
- `AutocompleteDropdown` (`lib/widgets/autocomplete_dropdown.dart`) renders the
  raw suggestion strings with no conversion. This is the reported bug.
- Velthuis typing in `lib/utils/velthuis.dart` maps `.m → ṃ` unconditionally,
  ignoring the setting.

## Why putting `ṁ` into the search bar is safe (verified)

The database stores `ṃ` only. `DpdDao._normalizePunctuation()`
(`lib/database/dao.dart:762`) rewrites `ṁ→ṃ` and `ŋ→ṃ` before querying, and
every DPD-side query path goes through it — `searchExact`, `searchPartial`,
`searchFuzzy`, `searchClosestMatches`, `searchLookupKeysPrefix`,
`getLookupRow`, `searchRoots`, `searchDictWordsPrefix`.

**One gap found.** The external-dictionary search path does *not* normalise:

- `searchDictExact` (`dao.dart:648`) matches on a `stripDiacritics` fuzzy key
  (which folds both `ṁ` and `ṃ` to `m`, so it survives) but then re-filters with
  an exact `row.word.toLowerCase() == lowered` comparison, which fails when the
  query holds `ṁ` and the stored word holds `ṃ`.
- `searchDictPartial` (`dao.dart:665`) does a raw `LIKE 'word%'` on the
  unnormalised query.

Both are fed the raw query from `lib/providers/dict_provider.dart:317` and
`:327`. This is a pre-existing bug — a user who types `ṁ` by hand hits it
today — but this thread makes it reachable routinely, so it must be closed.

## What it should do

1. Whatever niggahīta character the setting names is the character the user sees
   in every piece of DPD-authored text and in the search bar.
2. The autocomplete dropdown shows the chosen character, and tapping a
   suggestion puts that same character into the search bar.
3. Typing `.m` in the search bar produces the chosen character.
4. Searching is unaffected by which character is on screen.

## Scope (confirmed with the user)

**In scope:** the search bar (including its Velthuis conversion and its
autocomplete dropdown) and DPD's own entry content — result cards, deconstructor
output, summary, inflection tables, family tables, root info and root matrix,
sutta info, frequency tables, search history, and the declension/conjugation
form sheets.

**External dictionaries — scope widened mid-thread.** These were initially out
of scope, on the reasoning that their content is third-party HTML. After testing
the rest, the user asked for them to follow the setting too: *"external dicts
should also show whatever the settings is. simple replace."* So Cone, CPD, DPPN
and the rest now get the same display conversion, applied as a plain string
replace over the entry HTML, its title, and its tooltip text.

This is safe against the markup: no HTML tag name or standard attribute contains
a niggahīta, and the one place a Pāḷi string is embedded in a URL — the
`tooltip:` links — stores it percent-encoded, so a literal `ṃ` never appears
there to be replaced. As everywhere else, the conversion is display-only; the
stored entry and the query used to find it stay canonical.

## Constraints

- Never use hardcoded colours; not relevant here but the project rule stands.
- Display conversion is presentational only. No stored value, no lookup key, no
  navigation argument, and no database column may be converted.
- Search history stores whatever the user committed; display conversion happens
  when the history entry is rendered, not when it is written.
- The project forbids UI tests. Tests here cover the conversion helper only.
- Existing behaviour of the four already-converted widgets must not change.

## Assumptions & uncertainties

- Assumed: the DB genuinely contains no `ṁ`. The exporter and every dao
  normalisation treat `ṃ` as canonical, and `filterNiggahita` only ever converts
  in the `ṃ→ṁ` direction, so a stray `ṁ` in the data would simply pass through
  unchanged in both modes. Low risk either way.
- Assumed: no code compares a displayed string back against a stored value. To
  be checked per site during implementation — any site that does gets the
  conversion applied at the `Text(...)` call only, never to the underlying value.
- Uncertain: whether every DPD display site has been found. The affected-file
  list below comes from a sweep of `Text(` call sites across `lib/widgets/` and
  `lib/screens/`; a stray site may surface during implementation and will be
  added to `plan.md` then.

## How we'll know it's done

- With `ṁ` selected: typing `sa` shows `saṁ…` suggestions; tapping one puts `ṁ`
  in the bar; the results, the entry page, its inflection and family tables, and
  the history panel all show `ṁ`.
- With `ṁ` selected, typing `sa.msaara` yields `saṁsāra` in the bar and finds the
  entry.
- Switching the setting back to `ṃ` restores `ṃ` everywhere without a restart.
- With `ṁ` in the bar, an enabled external dictionary still returns its exact
  match.
- `flutter test` passes.

## What's not included

- No change to how anything is stored, exported, or sent in feedback payloads.
- No new setting, and no change to the setting's own UI.
- The declension and conjugation feedback sheets keep the canonical form in
  their editable word field, since its contents are submitted as a report.
