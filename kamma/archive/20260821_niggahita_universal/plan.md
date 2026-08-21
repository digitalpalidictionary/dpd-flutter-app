# Plan — Niggahīta setting applies everywhere

## Architecture Decisions

**One mechanism, not two.** The four existing sites read the setting with
`ref.watch(settingsProvider.select(...))` and then bridge two enums by index
(`NiggahitaFilterMode.values[niggahitaMode.index]`). Most of the remaining
display sites are plain `StatelessWidget`s. Converting a dozen of them to
`ConsumerWidget` just to read one boolean is a lot of churn for no gain, and
leaving two different mechanisms in place is worse than either one alone.

Decision: expose the setting through an `InheritedWidget` (`NiggahitaScope`)
installed once above `MaterialApp`, with a `context.nigg(text)` extension. A
`StatelessWidget` stays a `StatelessWidget` and gains one call per rendered
string. Dependents rebuild automatically when the setting changes. The overlay
that hosts the autocomplete dropdown, and all bottom sheets, sit inside
`MaterialApp`'s navigator, so a scope above `MaterialApp` is an ancestor of all
of them.

The four existing sites migrate to the same mechanism so there is exactly one
way to do this. `filterNiggahita()` stays as the underlying pure function and
keeps its tests; `NiggahitaFilterMode` and the index bridge go away.

**Conversion at the leaf.** The conversion is applied at the `Text(...)` call,
never to the value held in a model, a map key, a navigation argument, or a
callback payload. This keeps tap-to-search, history, and feedback payloads
working on canonical `ṃ`.

**Dictionary query normalisation is a bug fix, not a feature.** Two dao methods
are given the same normalisation the DPD paths already have. Nothing else in
`dict_provider.dart` changes.

---

## Phase 1 — The mechanism

- [x] Add `NiggahitaScope` `InheritedWidget` plus a `context.nigg(String)`
      extension, in `lib/utils/text_filters.dart` (next to `filterNiggahita`,
      which it calls). It carries a single `bool circle`.
  → verify: `flutter analyze lib/utils/text_filters.dart` reports no errors

- [x] Install the scope in `lib/app.dart`, wrapping the `CallbackShortcuts` /
      `MaterialApp` subtree, fed from the already-watched `settings.niggahitaMode`.
  → verify: `flutter analyze lib/app.dart` reports no errors

- [x] Migrate the four existing sites — `inline_entry_card.dart`,
      `grammar_table.dart`, `accordion_card.dart`, `entry_content.dart` — from
      their local `n()`/`f()` helpers to `context.nigg(...)`. Delete
      `NiggahitaFilterMode` and the `.values[...index]` bridge; update
      `test/utils/text_filters_test.dart` to test the new signature.
  → verify: `flutter analyze` reports no errors; `flutter test` passes

---

## Phase 2 — The search bar

- [x] Convert autocomplete suggestions for display in
      `lib/screens/search_screen.dart` `_showOverlay()`, so both the dropdown
      and the text placed in the bar by `_onSuggestionSelected` carry the chosen
      character.
  → verify: with `ṁ` selected, type `sa`; dropdown shows `saṁ…`; tap one and the
    bar shows `ṁ`; results are the same entries as with `ṃ` selected

- [x] Apply the setting to the Velthuis conversion at
      `lib/screens/search_screen.dart:127`, leaving `lib/utils/velthuis.dart`
      itself producing canonical `ṃ`.
  → verify: with `ṁ` selected, type `sa.msaara`; bar shows `saṁsāra` and the
    entry is found. With `ṃ` selected, it shows `saṃsāra`

- [x] Normalise the query in `DpdDao.searchDictExact` and
      `DpdDao.searchDictPartial` (`lib/database/dao.dart`), closing the `ṁ` gap
      in external dictionary search.
  → verify: with an external dictionary enabled and `ṁ` selected, search a word
    containing niggahīta and confirm the exact-match card still appears

### Deviations from the plan, recorded during Phase 2

- **`canonicalNiggahita()` added** to `lib/utils/text_filters.dart`. The plan
  assumed display conversion alone was enough. It is not: once the bar holds
  `ṁ`, that character flows into the query and into search history. The screen
  now folds it back at every point where displayed text re-enters the data layer
  — `_onChanged`, `_onSearch`, `_onSuggestionSelected` — so history and queries
  stay canonical whatever is on screen. Covered by new tests.

- **`_onSuggestionSelected` switched to `_setSearchQuery`.** It wrote
  `searchQueryProvider` directly, without `_suppressProviderSync`. With the
  query now canonical and the field showing `ṁ`, the provider→controller
  listener would have seen a mismatch and clobbered the field straight back to
  `ṃ`, silently defeating the whole fix. Using the existing suppressing setter
  fixes it and matches what `_onSearch` already did.

- **Two more search-bar seeding paths converted**, both external entry points
  the plan missed: the `searchQueryProvider` listener (share intents, deep
  links, double-tap word search) and the `initState` post-frame seed (external
  cold start). Without these the field shows `ṃ` on any externally-driven search.

- **`_foldNiggahita()` extracted in `dao.dart`** rather than reusing
  `_normalizePunctuation` as planned. `_normalizePunctuation` also strips
  hyphens and apostrophes, which would have changed which external dictionary
  entries match. The new helper folds niggahīta only, and
  `_normalizePunctuation` now delegates to it so there is one definition.

---

## Phase 3 — DPD entry display sites

Apply `context.nigg(...)` to Pāḷi strings rendered by each. Sweep each file for
`Text(` call sites carrying DPD text; skip English labels and headings.

- [x] `lib/widgets/split_results_list.dart` — accordion titles, compact
      deconstructor/meaning/spelling/see lines, compact grammar rows, compact
      EPD headwords, compact variant rows
- [x] `lib/widgets/secondary/secondary_card.dart` — the title of every expanded
      secondary card, in one place for both card shells
- [x] `lib/widgets/secondary/secondary_result_cards.dart` — deconstructor lines,
      grammar table cells, abbreviation meanings and notes, help/abbreviation
      values, EPD headwords, variant cells, spelling and see lists
- [x] `lib/widgets/summary_section.dart` — lemma, suffix, label and meaning spans
- [x] `lib/widgets/inflection_table.dart` — inflected form stem and ending
- [x] `lib/widgets/family_table.dart` — lemma, meaning, completion
- [x] `lib/widgets/family_section_builders.dart` — all five family headers, via
      the one shared `_richHeader` they funnel through
- [x] `lib/widgets/multi_family_section.dart` — the jump-to family key links
- [x] `lib/widgets/root_info_table.dart`, `lib/widgets/root_matrix_table.dart`,
      `lib/widgets/inline_root_card.dart` — root text, matrix cells, family
      buttons
- [x] `lib/widgets/history_panel.dart` — history entries (display only; stored
      value unchanged)
- [x] `lib/screens/entry_screen.dart` and `lib/screens/root_screen.dart` — app
      bar lemma/root titles, grammar line, root meaning, notes
- [x] `lib/widgets/entry_content.dart` — `buildKvTextRow` and `buildKvRichRow`,
      the shared key-value row builders, which covers the root info table and
      sutta info rows without touching either file
  → verify (per file): `flutter analyze <file>` reports no errors

- [x] Phase verification: `flutter analyze` clean, `flutter test` passes, and a
      grep confirms no remaining `filterNiggahita(` call outside
      `text_filters.dart` and its test.
  → verify: `flutter analyze && flutter test` both succeed

### Deviations from the plan, recorded during Phase 3

- ~~**`lib/widgets/frequency_table.dart` — no change needed.**~~ **This claim was
  wrong and was corrected in Phase 5.** It renders two Pāḷi row labels
  containing niggahīta, `Saṃyutta` and `Vaṃsa`. The original sweep skimmed the
  rendering helpers and never grepped the file for the character itself.

- **`lib/widgets/sutta_info_section.dart` — data rows need no direct change.**
  Every data row routes through `buildKvTextRow` / `buildKvLinkRow`, which are
  converted centrally, and URLs are deliberately left alone. One hard-coded link
  label (`SC Saṃyutta Card`) was missed and fixed in Phase 5.

- **The two form sheets were deliberately left canonical.** `declension_form_sheet`
  and `conjugation_form_sheet` contain no read-only Pāḷi display at all — their
  only Pāḷi is an *editable* `TextFormField` whose contents are submitted as the
  feedback payload. Converting it would put `ṁ` into user-submitted reports,
  which the spec forbids. Pre-filling with `ṁ` and folding back on submit was
  rejected as complexity nobody asked for on a feedback form.

- **Three files not in the plan were converted:** `secondary_card.dart` and
  `family_section_builders.dart` (both shared choke points that covered many
  display sites in a single edit) and `entry_screen.dart` / `root_screen.dart`
  (app bar titles, which show the lemma and root on every entry page).

- **A `dart format lib/` run had to be undone.** It reformatted 75 files, far
  beyond this thread's scope. All files were reverted to pristine and every edit
  re-applied by targeted replacement with no formatter run. One file
  (`entry_screen.dart`) uses CRLF line endings, which a scripted rewrite
  silently converted to LF; the original endings were restored. The analyzer is
  back at its exact pre-thread baseline of 51 infos and zero errors.

---

## Phase 4 — External dictionaries (added mid-thread at the user's request)

After confirming Phases 1–3 on device, the user widened the scope: external
dictionary entries should follow the setting too, as a simple replace.

- [x] `lib/widgets/dict_html_card.dart` — apply the conversion to the entry
      title, the prepared entry HTML, and the decoded tooltip text.
  → verify: `flutter analyze` clean, `flutter test` passes, line endings
    unchanged on every touched file

---

## Phase 5 — Review fixes

Raised by an independent reviewer and CodeRabbit after the user had tested and
approved Phases 1–4. All verified against the code before being applied.

- [x] **BLOCKING — tap-to-search wrote the display character into saved history.**
      `_getWordAtPosition` scrapes `RenderParagraph.toPlainText()`, i.e. the
      *rendered* string. Once entries rendered `ṁ`, a tapped word carried `ṁ`
      into `searchQueryProvider` and into `historyProvider`, which persists to
      SharedPreferences. Because the display filter only ever converts `ṃ→ṁ`,
      those saved entries would keep showing `ṁ` even after switching back —
      making the setting irreversible for anything reached by tapping. Fixed by
      folding to canonical in `_cleanPali`, and, per the project's "two search
      paths" rule, in `IntentService._clean` as well.
- [x] **MAJOR — the search bar did not react to toggling the setting.** Every
      `context.nigg` call in `search_screen` sat in a callback, never in `build`,
      so no `InheritedWidget` dependency was registered and nothing rewrote the
      field. Fixed with a `ref.listen` on the setting inside `build` that
      re-renders the field from its canonical form. Both characters are one
      UTF-16 unit, so the cursor selection stays valid.
- [x] **MAJOR — the Phase 3 sweep was incomplete.** Twelve further sites fixed:
      the no-results screen and its closest-match list, the frequency section
      heading, two frequency table row labels, the `saṃyutta` section button, the
      `SC Saṃyutta Card` link label, the recent-search chips on the home screen,
      the root family buttons in `inline_root_card` and `root_screen`, the search
      field after tapping a recent chip, and the back/forward history tooltips.
- [x] **MINOR — `_richHeader` rebuilt spans lossily**, copying only text, style
      and children and silently dropping `recognizer`, `semanticsLabel`, `locale`
      and `mouseCursor`. Harmless today, a trap tomorrow. Replaced by converting
      inside `_bold` and `_normal` instead.
- [x] **NIT — leftover `final lowered = normalized;`** alias in `dao.dart`
      inlined; over-long line in `root_matrix_table.dart` wrapped.
  → verify: `flutter analyze` at baseline, `flutter test` passes, line endings
    unchanged on every touched file

### Reviewer findings investigated and dismissed, with evidence

- **"External dictionary HTML may store niggahīta as an entity (`&#7747;`)"** —
  disproven against the real 241,653-row dictionary database: zero entries use
  entity encoding, 72,243 use the literal character. The plain replace is correct.
- **"A converted URL could be corrupted"** — disproven: 396,837 `href` values
  across 194,085 entries were extracted and checked; none contains a literal
  niggahīta.
- **"Grammar table double-converts"** — real but deliberately left alone. Its `n`
  helper is also called directly into two `Text` widgets, so it must keep
  applying the conversion; the second application inside the row builders is the
  same idempotent function, not a second mechanism. Removing it would mean more
  code, not less.

---

## Finalize

- [ ] Full smoke pass, review, finalize
