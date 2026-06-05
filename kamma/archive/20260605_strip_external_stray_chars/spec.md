# Spec: Strip stray characters from external (shared) searches

## Overview
Text shared into DPD from other Pāḷi apps/websites often carries stray
formatting characters — most commonly markdown emphasis like *dhamma*,
_dhamma_, `dhamma`, ~dhamma~, plus #, >, |. These reached the search query
and corrupted the lookup.

## What it should do
Sanitize all externally-supplied search text so only characters valid in a
Pāḷi search remain, regardless of script; and ensure the cleaned word is
shown (and editable) in the search bar after an external lookup.

## Current behavior (affected code)
- `lib/services/intent_service.dart` → `_clean()` used a BLACKLIST
  (`_quotePattern`, `_bracketPattern`) so markdown chars passed through.
- All external entry points route through `_clean()`: `intentStream`
  (Android ACTION_SEND / PROCESS_TEXT), `lookupStream` (Linux hotkey),
  `getInitialText()` → `_IntentBoot` (cold launch / CLI).

## Approach
1. Replace the quote+bracket blacklist with a single Unicode ALLOWLIST that
   keeps letters (\p{L}), combining marks (\p{M}), digits (\p{N}),
   whitespace, apostrophe, hyphen, period. URL stripping retained, runs
   first. Curly single quotes normalised to straight '. ' - . trimmed at
   word edges (valid only word-internally).
2. Seed the search field from current provider state when `SearchScreen`
   first mounts (post-frame), because on external cold start the query is
   set before the screen mounts and the change-listener never fires for it.

## Decisions (from user)
- Keep digits + period so sutta refs like SN12.34 survive.
- Keep ' and - as the only internal punctuation (Pāḷi elision / compounds);
  everything else is stray.

## Constraints
- Tap-to-search path (`_cleanPali`) left unchanged: it reads already-clean
  in-app text; per AGENTS.md two-path rule it was checked, not the source
  of stray chars.
- No UI tests (AGENTS.md). Logic tests only.
- Provider writes must not happen during initState/build (Riverpod crashes).

## How we'll know it's done
- New IntentService.clean tests pass (markdown, apostrophe-kept,
  hyphen-kept, Devanagari) + all existing tests pass.
- Cold-start share shows the word in the editable search bar without crash.

## What's not included
- Tap-to-search cleaning changes.
- Apostrophe-preservation rework beyond keeping internal ones.
