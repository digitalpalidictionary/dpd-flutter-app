# Thread Spec
Issue reference: GitHub issue #13 - "Add external searches to history list"

## Overview
External searches are not being recorded in the app's search history. Searches triggered through share/process-text flows, Linux lookup/hotkey flows, or other external entry points update the active search query, but they do not pass through the same history-recording path used by in-app committed searches. The issue also reports a first-search bug for externally triggered lookups, which needs to be fixed as part of the same behavior-parity change.

I checked the current issue state with `gh issue view 13 --comments`: the issue is open, has no comments, and its body matches the inline description. I also ran `git log --oneline --all --grep='#13'` and found no issue-tagged commits related to this work.

## What it should do
When a search is triggered externally, the searched word must be added to the same history list used by normal in-app searches.

This must apply to all external entry points currently used by the app:
- cold-start launches via CLI args handled in `lib/main.dart` by `_IntentBoot`
- runtime share/process-text events handled in `lib/app.dart` via `IntentService.intentStream`
- Linux lookup events handled in `lib/app.dart` via `IntentService.lookupStream`

The externally triggered search should:
- update the displayed search text exactly as it does now
- update the normalized lookup query exactly as it does now
- add the committed search term to history once
- correctly record the very first externally triggered search

Internal search behavior must remain unchanged:
- typed searches committed with the search button / submit
- autocomplete selection
- tap-to-search flows
- back/forward history navigation
- existing search bar display behavior that preserves original script via `searchBarTextProvider`

## Constraints
- Keep the change strictly limited to behavior parity for external search entry points.
- Do not alter adjacent history semantics beyond what is needed to record external committed searches correctly.
- Preserve the project rule that external entry points must be explicitly reviewed: `intentStream`, `lookupStream`, and `_IntentBoot`.
- Preserve the search bar rule from repo instructions: provider/controller sync must not overwrite the user-visible original script except through the existing `searchBarTextProvider` path.
- Reuse existing history-recording rules from `lib/utils/history_recording.dart` rather than introducing a separate definition of what counts as a committed search.
- Add tests only for non-UI/data logic behavior; do not add UI tests.

## How we'll know it's done
- External searches from all three entry points are recorded in history.
- The first externally triggered search is present in history without requiring a second external search.
- Existing internal search history behavior still works.
- Automated tests cover the external history-recording logic and pass locally.

## What's not included
- Redesigning the history feature or history UI.
- Changing duplicate handling, ordering, max-entry limits, or persistence format beyond what existing history behavior already does.
- Refactoring unrelated search-provider or intent-service architecture.
- Adding widget/UI tests.
