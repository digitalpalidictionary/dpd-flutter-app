# Plan: Home Screen Improvements

## Architecture Decisions
- Word of day logic lives in DAO (DB concern) + a FutureProvider (caching)
- HomeContent widget replaces EmptyPrompt entirely; empty_prompt.dart is no longer shown for empty state
- Logo tap clears the search query via a new `_goHome()` method
- Recent chips reuse the existing historyProvider — no new state
- Eligibility filter uses degreeOfCompletion == '✔' criteria: ebt_count > 0, meaning1 IS NOT NULL, source1 IS NOT NULL

## Phase 1: DAO + Provider
- [x] Add `fetchWordOfDay(DateTime date)` to dao.dart
  - COUNT headwords with ebt_count > 0 + meaning1/source1 IS NOT NULL
  - Use date as int seed (YYYYMMDD), pick offset with Random(seed).nextInt(count)
  - SELECT with isEligible, ORDER BY id, LIMIT 1 OFFSET idx (joined with roots)
  - Returns DpdHeadwordWithRoot?
  → verify: flutter analyze passes with no new errors ✔

- [x] Create `lib/providers/word_of_day_provider.dart`
  - FutureProvider<DpdHeadwordWithRoot?> that calls dao.fetchWordOfDay(DateTime.now())
  - Watches daoProvider
  → verify: flutter analyze passes ✔

## Phase 2: HomeContent widget
- [x] Create `lib/widgets/home_content.dart`
  - Watches wordOfDayProvider and historyProvider
  - Word of the Day section: CircularProgressIndicator while loading,
    then card with lemma1 (titleMedium bold), pos (bodySmall), meaning1 (bodyMedium, maxLines 2)
    wrapped in InkWell → Navigator.pushNamed('/entry', arguments: hw.headword.id)
  - Recent Searches section: up to 10 entries from history, rendered as Wrap of ActionChips
  - Uses DpdSectionContainer for card border, colorScheme only for colors
  → verify: flutter analyze passes ✔

- [x] Wire HomeContent into SearchScreen in place of EmptyPrompt
  - Added `_searchFromHome(String query)` method that sets controller + provider + history
  - Replaced EmptyPrompt() with HomeContent(onSearch: _searchFromHome)
  → verify: flutter analyze passes ✔

## Phase 3: Header tap to home
- [x] Wrap logo stack + title Text in GestureDetectors in search_screen.dart
  - Added `_goHome()` method: clears controller, clears query provider, unfocuses keyboard
  - Logo SizedBox wrapped in GestureDetector(onTap: _goHome)
  - Title Text wrapped in GestureDetector(onTap: _goHome) inside Expanded
  → verify: flutter analyze passes ✔

## Phase 4: Verification
- [x] flutter analyze — no new errors or warnings in modified files
