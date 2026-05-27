# Spec — Remove redundant magnifying-glass search button

## Overview
The search bar row in `lib/screens/search_screen.dart` currently has a dedicated magnifying-glass `_BarIconButton` that calls `_onSearch()`. This button is redundant.

## What it should do
Remove the magnifying-glass button from the search bar row. The Clear (X) button and history Back/Forward buttons stay in place.

## Affected files
- `lib/screens/search_screen.dart` — the only file changed.

## Current behavior (lines ~569–573)
```dart
_BarIconButton(
  icon: Icons.search,
  onPressed: _onSearch,
  tooltip: 'Search',
),
```

## Why it's redundant
`_onSearch()` is also invoked via:
- Soft keyboard Search/Go key → `onSubmitted: (_) => _onSearch()` (line ~527)
- Hardware Enter → same `onSubmitted`
- Autocomplete suggestion selection → `_onSuggestionSelected` records to history
- Live debounced typing in `_onChanged` already updates results as user types

So the visual button only adds clutter; no functional capability is lost by removing it.

## Assumptions & uncertainties
- Assumption: Android soft keyboards reliably surface a Search/Go action key for `TextField` with `onSubmitted`. This is Flutter default behavior. Low risk.
- Assumption: No tests reference the magnifying-glass button. Project rule states no UI tests in this app, so this should hold.
- Assumption: `_onSearch` must remain defined since `onSubmitted` still calls it.

## Constraints
- Per AGENTS.md: do not add UI tests.
- Per AGENTS.md: do not commit unless explicitly asked.
- Scope strictly limited to deleting the one button. Do not touch X (Clear), Back, Forward, or any other element.

## How we'll know it's done
- The magnifying-glass button no longer appears in the search bar row.
- Search still triggers via Enter / soft keyboard Search key.
- `flutter analyze` passes with no new warnings.
- App builds and runs.

## What's not included
- Moving the X button inside the TextField as suffixIcon (separate decision, not requested here).
- Swapping the `?` (Velthuis help) icon placement.
- Any other search-row layout changes.
