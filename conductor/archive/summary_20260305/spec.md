# Spec: Summary Section

## Overview
Implement a summary section at the top of search results, matching the DPD webapp behavior. The summary displays one-line entries for all exact match result types (headwords, roots, see, grammar, spelling, variants, etc.) with clickable links that scroll to the corresponding entry below.

## Functional Requirements

1. **Summary Block** — Displayed above all detailed search results, separated visually (matching webapp placement).
2. **Result Types** — Include all lookup result types in the summary: headwords, roots, "see also", grammar, spelling, variants, and any other categories present in the webapp summary.
3. **One-Line Format** — Each summary entry shows a concise one-liner with lemma/key, type, meaning/description, and a ► link.
4. **Clickable Links** — Tapping a summary entry or its ► link smooth-scrolls to the corresponding full entry in the results below.
5. **Settings Toggle** — A "Show Summary" toggle in the settings screen, persisted via shared_preferences.
6. **Reactive Update** — Toggling the setting immediately shows/hides the summary without needing to re-search or navigate back.

## Non-Functional Requirements

1. **No manual verification until complete** — Do not ask the user for manual verification until the entire feature is finalized. Only one manual verification at the very end.

## Acceptance Criteria

- [ ] Summary section appears above results for any search with exact matches
- [ ] All webapp summary types are represented (headwords, roots, see, grammar, spelling, variants, etc.)
- [ ] Tapping a summary link smooth-scrolls to the target entry
- [ ] Summary visibility is controlled by a setting toggle
- [ ] Toggling the setting reactively updates the UI in real-time
- [ ] Summary is hidden when the setting is off
- [ ] No summary shown when there are no exact matches

## Out of Scope

- Partial match summaries
- Summary for deconstructor results
