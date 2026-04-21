# Spec: Logical history branching and back navigation

## Overview
Search history currently mixes two different behaviors into one structure:

- recency-sorted search history for the history sheet
- back/forward navigation for the toolbar and Android back button

This causes illogical branching behavior. For example, if the user goes back to
word `A`, opens word `B` from `A`'s examples, and then presses Back, the app
does not reliably return to `A`. The visible history list has been reordered by
recency, so navigation follows that reordered list instead of the path the user
actually took.

The long-term fix is to separate navigation history from recent-search history.

## What it should do
- Back/forward navigation must follow the user's actual traversal path, not the
  recency order of the history sheet.
- When the user goes back to an earlier word and then opens a new word, the app
  must treat that as a branch:
  - the old forward path is discarded
  - the new word becomes the current navigation entry
  - pressing Back returns to the word the branch came from
- The history sheet must remain a recent-search list:
  - deduplicated by query
  - newest first
  - timestamped as it is now
- Tapping a word in the history sheet must count as a new navigation event:
  - it should open that word
  - it should update recent-search recency
  - it should prune any forward navigation branch first, if the user was not at
    the top of the navigation stack
- Android Back must keep matching the toolbar back arrow behavior exactly.
- Existing external search entry points must continue to participate correctly:
  - `_IntentBoot` in `lib/main.dart`
  - `intentStream` in `lib/app.dart`
  - `lookupStream` in `lib/app.dart`
- Clear history should define expected behavior explicitly:
  - clearing recent-search history should empty the history sheet
  - active session back/forward behavior should remain logical and must not
    break the current screen

## Assumptions & uncertainties
- The app should use one shared navigation model for toolbar back/forward,
  Android back handling, and any future navigation entry points.
- The current timestamped `HistoryEntry` model is still suitable for the
  recent-search list.
- Navigation history probably does not need timestamps; it only needs stable
  ordering and a current position.
- It is acceptable for recent-search persistence and navigation persistence to
  diverge if that produces clearer UX. A likely default is:
  - persist recent-search history as today
  - keep navigation stack session-local unless a strong reason appears to
    persist it

## Constraints
- Keep the fix focused on history semantics and behavior parity.
- Do not add UI tests.
- Reuse existing search commit rules from `lib/utils/history_recording.dart`.
- Preserve the search bar display-text rule: provider/controller sync must not
  overwrite original-script text except through the existing intended path.
- Preserve exact behavior for overlay dismissal before Android back navigation.
- Avoid changing unrelated search, summary, or entry rendering behavior.

## How we'll know it's done
- Starting from a sequence like `A -> B -> C`, pressing Back walks `C -> B -> A`
  regardless of recent-search ordering.
- If the user goes back from `C` to `A`, then opens `D`, the app creates a new
  branch:
  - Back goes from `D` to `A`
  - Forward to the old `B/C` path is no longer available
- The history sheet still shows the most recently used searches in recency
  order, independent of back/forward traversal.
- Tapping a recent-search item opens it as a new navigation event and preserves
  logical Back behavior.
- Android Back and the toolbar back arrow land on the same destination in all
  tested cases.
- External entry points still record committed searches correctly and do not
  bypass the new navigation model.
- Automated tests cover branching, forward-pruning, recent-search ordering, and
  external search behavior.

## What's not included
- Visual redesign of the history sheet.
- Multi-tab or tree-style history UI.
- New user settings for history behavior.
- Persisting a full branch tree for later restoration.
