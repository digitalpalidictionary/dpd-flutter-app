# Spec: Gray Out Non-Occurring Inflection Forms

## Overview

Gray out inflected forms in the inflection table that do not occur in any recognized
Pāḷi text. The webapp already does this using a `span.gray` CSS class — this track
brings the same behavior to the Flutter app.

The key insight is that the `lookup` table already contains every recognized inflected
form. Instead of shipping an extra wordlist, we load the lookup table keys into memory
and cross-reference them when building inflection tables.

## Functional Requirements

### FR-1: Load Lookup Keys into Memory
- After the UI has loaded (in the background, before the user starts searching),
  load all keys from the `lookup` table into a `Set<String>`.
- Cache this set for the lifetime of the app session.
- This must not block the UI thread or delay app startup.

### FR-2: Pass Occurring Set to Inflection Builder
- When building an inflection table, pass the lookup key set to `buildInflectionTable()`.
- For each inflected form (`stem + ending`), check if the word exists in the set.
- Add an `isOccurring` boolean field to `InflectionForm`.

### FR-3: Style Non-Occurring Forms as Gray
- Forms where `isOccurring == false` are rendered in gray.
- Color: `hsl(0, 0%, 50%)` / `#808080` — matching the webapp's `--gray` CSS variable.
- Add this color to the app's theme as a named semantic color.
- Occurring forms remain styled as they are today (default text color).
- The existing blue highlight for search-match (`lookupKey`) takes precedence over gray.

### FR-4: Graceful Degradation
- If the lookup key set hasn't loaded yet when an inflection table is opened,
  render all forms in default color (no gray). No blocking or waiting.

## Non-Functional Requirements

- No additional data stored in the database — uses existing `lookup` table keys.
- Memory: the set will consume ~10-20 MB in memory (acceptable for mobile).
- Background loading should complete well before the user navigates to an inflection table.

## Acceptance Criteria

1. Inflection tables show non-occurring forms in gray (#808080).
2. Occurring forms display in the normal text color.
3. Search-match highlighting (blue background) still works and takes precedence.
4. App startup is not visibly slower.
5. If lookup set hasn't loaded, inflection tables render normally (no crash, no gray).

## Out of Scope

- Dark mode-specific gray color (webapp uses same gray for both modes).
- Changes to the dpd-db Python codebase or mobile exporter.
- Bloom filters or compressed wordlists.
