# Future TODOs

## Existing TODOs

### Forward and backwards buttons

### Inflection Tables
- [ ] Gray out unattested forms: bundle `all_tipitaka_words` set at build time, add `span.gray` styling for forms not found in the canon
- [ ] Remove `inflections_html` column from database to reduce DB size (once dynamic tables are verified)

### Family Tables
- [ ] Optimize mobile.db: copy only `data` + `count` columns from family tables (~10 MB total for all five), drop `html` column (useless for Flutter native widgets)
- [ ] Consider building family data from scratch via headword queries instead of pre-compiled tables — would eliminate family tables entirely but requires replicating `meaning_combo` and `degree_of_completion` logic in Dart
- [ ] Add build-and-cache strategy: compute family data on first access, store in memory cache with LRU eviction to bound memory usage
- [ ] Add clickable lemma links in family tables to navigate to other entries

---

## Webapp → Flutter Feature Gap (2026-03-01)

Systematic comparison of webapp templates (`dpd_headword.html`, `root.html`, `home.html`, `bold_definitions.html`, `variant.html`, `deconstructor.html`) against Flutter app widgets and screens.

### Priority Legend
- **P0** — Core webapp parity (entry display features)
- **P1** — Important user-facing features
- **P2** — Nice-to-have / secondary features
- **P3** — Stretch goals / low priority

---

### P0 — Entry Display Parity

#### 2. IPA Pronunciation (Complete Implementation)
**Status:** Placeholder in grammar table (displays "—" with gray play button)
**Webapp:** IPA transcription with play buttons for male1, male2, female1 audio variants
**Work:**
- [ ] Add `lemma_ipa` computed column to database (Aksharamukha)
- [ ] Display actual IPA text in grammar table row
- [ ] Investigate audio playback feasibility

#### 3. Audio Playback
**Status:** Not implemented
**Webapp:** Play button in button row; play buttons in grammar table for IPA variants; audio gender toggle in settings
**Work:**
- [ ] Determine audio source strategy (bundled vs. streamed vs. TTS)
- [ ] Add play button to button row
- [ ] Implement audio player service
- [ ] Add audio gender setting to settings screen
- [ ] Wire play buttons in grammar table IPA row

#### 4. Entry Screen Completeness
**Status:** EntryScreen missing Frequency and Feedback sections
**Work:**
- [ ] Add Frequency button + section to EntryScreen
- [ ] Add Feedback button + section to EntryScreen

#### 5. Accordion Card Completeness
**Status:** AccordionCard missing Frequency and Feedback buttons
**Work:**
- [ ] Add Frequency button + section to AccordionCard
- [ ] Add Feedback button + section to AccordionCard

---

### P1 — Important User-Facing Features

#### 6. Search History
**Status:** Not implemented
**Webapp:** Collapsible history pane; clear history button; click to revisit
**Work:**
- [ ] Create search history model/storage (SharedPreferences or SQLite)
- [ ] Add history panel to search screen (collapsible)
- [ ] Add clear history button
- [ ] Tap on history item re-executes search

#### 7. One-Button-at-a-Time Mode
**Status:** Not implemented
**Webapp:** Settings toggle; opening one section closes all others
**Work:**
- [ ] Add one-button toggle setting to settings screen
- [ ] Implement exclusive section visibility logic in button handlers
- [ ] Apply to all display modes

#### 8. Niggahīta Display Toggle (ṃ/ṁ)
**Status:** Not implemented
**Webapp:** Settings checkbox toggles display between ṃ and ṁ throughout the app
**Work:**
- [ ] Add niggahīta setting to settings screen
- [ ] Create text transform utility to swap ṃ↔ṁ
- [ ] Apply transform to all displayed Pāḷi text

#### 9. Summary Visibility Toggle
**Status:** Not implemented
**Webapp:** Settings checkbox shows/hides the summary section on entries
**Work:**
- [ ] Add summary visibility setting to settings screen
- [ ] Conditionally render EntrySummaryBox based on setting

#### 10. Sandhi Apostrophe Visibility Toggle
**Status:** Not implemented
**Webapp:** Settings checkbox shows/hides sandhi break apostrophes
**Work:**
- [ ] Add sandhi visibility setting to settings screen
- [ ] Apply show/hide logic to relevant text fields

#### 11. Velthuis Typing Help
**Status:** Velthuis conversion works but no help/guide UI
**Webapp:** Help button next to search box with tooltip showing conversion table
**Work:**
- [ ] Add help icon button next to search bar
- [ ] Create tooltip or dialog showing Velthuis conversion table

#### 12. Deconstructor Section
**Status:** Not implemented
**Webapp:** Shows automated word breakups (sandhi splitting) for compound words
**Work:**
- [ ] Determine data source for deconstructor results
- [ ] Add deconstructor display section/button
- [ ] Show word breakup results with explanation text

#### 13. Variants Section
**Status:** Not implemented
**Webapp:** Table showing variant readings across corpora with context, source, filename, variant text
**Work:**
- [ ] Determine data source for variant readings
- [ ] Create `VariantsSection` widget with table display
- [ ] Add "Variants" button to button rows

---

### P2 — Secondary Features

#### 14. Root Entry Page
**Status:** Not implemented
**Webapp:** Separate page for Pāḷi roots: root summary, root info, root matrix, root family buttons
**Work:**
- [ ] Create `RootScreen` or `RootEntryView`
- [ ] Display root summary (root, meaning, group, sign)
- [ ] Add "Root info" button + section
- [ ] Add "Root matrix" button + section
- [ ] Add dynamic root family buttons + sections
- [ ] Navigation from headword grammar table root → root page

#### 15. Bold Definitions Search
**Status:** Not implemented
**Webapp:** Separate tab for searching bold definitions in commentaries: dual search fields, regex/fuzzy modes, results table with highlighting
**Data source:** `BoldDefinition` table (in DB models)
**Work:**
- [ ] Add `BoldDefinition` Drift table to `tables.dart`
- [ ] Create search UI with dual input fields
- [ ] Implement search modes (starts with, regex, fuzzy)
- [ ] Create results list with highlighting
- [ ] Add as separate tab or screen

#### 16. Tipiṭaka Text Search
**Status:** Not implemented
**Webapp:** Tab for searching Pāḷi texts and English translations with language/book filters
**Work:**
- [ ] Determine if text corpus data is available in mobile DB
- [ ] Create search UI with language and book filters
- [ ] Implement text search and results display

#### 17. Language Support (i18n)
**Status:** English only
**Webapp:** English/Russian language switcher
**Work:**
- [ ] Add i18n framework (flutter_localizations)
- [ ] Extract UI strings to localization files
- [ ] Add Russian translations
- [ ] Add language selector to settings

#### 18. Grammar/Examples Default Open State Verification
**Status:** Settings exist, may not apply to all display modes
**Work:**
- [ ] Verify default open state applies to all display modes
- [ ] Fix any modes where default state is not respected

---

### P3 — Stretch Goals

#### 19. Website Link Fix
**Status:** Placeholder (empty onTap handler in settings)
**Work:**
- [ ] Wire up dpdict.net link to url_launcher

#### 20. Mailing List Link
**Status:** Not implemented
**Work:**
- [ ] Add mailing list link to settings or about section

#### 21. Documentation Links
**Status:** Partially implemented (feedback section has "Read the docs")
**Work:**
- [ ] Ensure all doc links work throughout the app
- [ ] Add main documentation link in settings/about

#### 22. Accessibility Audit
**Status:** Basic Flutter accessibility only
**Work:**
- [ ] Audit and add Semantics widgets where needed
- [ ] Ensure keyboard navigation works on Chromebook/desktop
- [ ] Test with screen readers

#### 23. Traditional Lemma Display
**Status:** Grammar table row exists but `lemmaTradClean` is a static placeholder
**Work:**
- [ ] Implement `lemmaTradClean` computation (or add as DB column)
- [ ] Display actual traditional lemma in grammar table

---

## Summary Table

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | Sutta Info Section | P0 | Not implemented |
| 2 | IPA Pronunciation | P0 | Placeholder |
| 3 | Audio Playback | P0 | Not implemented |
| 4 | Entry Screen Completeness | P0 | Partial |
| 5 | Accordion Card Completeness | P0 | Partial |
| 6 | Search History | P1 | Not implemented |
| 7 | One-Button-at-a-Time Mode | P1 | Not implemented |
| 8 | Niggahīta Toggle (ṃ/ṁ) | P1 | Not implemented |
| 9 | Summary Visibility Toggle | P1 | Not implemented |
| 10 | Sandhi Apostrophe Toggle | P1 | Not implemented |
| 11 | Velthuis Typing Help | P1 | Not implemented |
| 12 | Deconstructor Section | P1 | Not implemented |
| 13 | Variants Section | P1 | Not implemented |
| 14 | Root Entry Page | P2 | Not implemented |
| 15 | Bold Definitions Search | P2 | Not implemented |
| 16 | Tipiṭaka Text Search | P2 | Not implemented |
| 17 | Language Support (i18n) | P2 | Not implemented |
| 18 | Default Open State Verification | P2 | Verify needed |
| 19 | Website Link Fix | P3 | Placeholder |
| 20 | Mailing List Link | P3 | Not implemented |
| 21 | Documentation Links | P3 | Partial |
| 22 | Accessibility Audit | P3 | Basic only |
| 23 | Traditional Lemma | P3 | Placeholder |
