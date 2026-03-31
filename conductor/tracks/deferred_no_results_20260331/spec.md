# Specification: Defer No-Results Message Until Search Completes

## Overview

Fix the search screen so the `No results for "{query}"` message is shown only after all relevant search sources have finished loading for the current query.

This track follows the long-term solution option: replace the current scattered empty-state checks with a single aggregated search-state model that distinguishes `loading`, `loaded-empty`, and `loaded-with-results` across all search providers.

## Background

- The current search UI in `lib/screens/search_screen.dart` combines multiple async providers directly in the widget.
- Several providers are read using `valueOrNull ?? []`, which makes `still loading` indistinguishable from `finished with no results`.
- The current fallback path waits for fuzzy DPD results, but can still treat external dictionary results as empty while they are loading.
- This produces a visible false negative: `No results` flashes first, then dictionary results appear.

## Functional Requirements

### FR1: Unified Search Completion State
- Introduce a single aggregated search-state layer for the search screen.
- The aggregated state must combine these sources for the current query:
  - exact headword results
  - partial headword results
  - root results
  - secondary results
  - external dictionary exact and fuzzy results
  - fuzzy fallback results
- The aggregated state must preserve the distinction between:
  - still loading
  - loaded with at least one result
  - fully loaded with no results

### FR2: Correct No-Results Timing
- The `No results for "{query}"` message must only appear after every relevant provider for that query has settled.
- While any relevant provider is still loading, the UI must remain in a loading or transitional state rather than showing a no-results message.
- The bug where dictionary cards appear after a premature no-results message must be eliminated.

### FR3: Preserve Current Search Ordering and Content
- Existing result ordering must remain unchanged.
- Existing exact-match, partial-match, root, secondary, and dictionary content must still render as before.
- Existing fuzzy fallback behavior must remain intact, except for the corrected timing of the empty state.

### FR4: Logic-Level Test Coverage
- Add or update tests for the aggregated search-state logic only.
- Tests must cover these cases:
  - one or more providers still loading
  - all providers loaded and empty
  - dictionary results arriving after fuzzy results
  - at least one source returning results
- No widget or UI rendering tests are required for this track.

## Non-Functional Requirements

- Keep the implementation minimal and easy to reason about.
- Prefer consolidating state decisions into provider logic instead of duplicating conditional checks in the widget tree.
- Avoid changing the search provider APIs more than necessary.
- Maintain compatibility with the existing Riverpod architecture and current search result models.

## Acceptance Criteria

1. Searching a term with delayed dictionary results never shows `No results` before those dictionary results appear.
2. Searching a term with truly no matches across all search sources shows `No results for "{query}"` only after all search work finishes.
3. Searching a term with exact, partial, root, secondary, fuzzy, or dictionary results continues to show those results without regression.
4. Logic tests cover the loading-versus-empty distinction and pass successfully.
5. No widget tests are added for this track.

## Out of Scope

- Redesigning the visual style of the search screen
- Changing the result ranking or source ordering
- Reworking unrelated search performance behavior
- Adding new result sources
