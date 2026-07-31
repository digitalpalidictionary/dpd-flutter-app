# Spec: Deep Linking (custom `dpd://` scheme)

## Overview
External websites (starting with dhamma.gift) should be able to open the DPD app
directly at a specific word via a clickable link, e.g. `dpd://word/bhavana`. This is a
one-tap lookup path distinct from the existing share-intent and floating-bubble paths.
A collaborator at dhamma.gift has asked whether to wire DPD into their site's "dictionary"
settings; the reply depends on the app exposing a stable, documented link scheme.

## Background — the existing external-entry funnel (verified by reading source)
The app already has a single, well-tested funnel for "look up this word from outside":

- **Native** (`android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/MainActivity.kt`):
  `extractText(intent)` pulls text from `ACTION_SEND` (`EXTRA_TEXT`) and `ACTION_PROCESS_TEXT`
  (`EXTRA_PROCESS_TEXT`). Cold start → method-channel `getInitialText`. Warm launch →
  `onNewIntent` → `emitWord` → event-channel `net.dpdict.app/intent/stream`. `MainActivity`
  is `singleTask`, so warm launches reuse the instance and fire `onNewIntent`.
- **Dart** (`lib/services/intent_service.dart` + `lib/providers/search_provider.dart`):
  `getInitialText()` and `intentStream` both route the raw text through
  `IntentService._clean()` (strips URLs and stray punctuation; keeps letters / combining
  marks / digits / space / `'-.`), then `_IntentBoot` (`lib/main.dart`) and the listeners in
  `lib/app.dart` call `externalSearchHandlerProvider.apply(text)`, which sets
  `searchBarTextProvider` (original-script display) + `searchQueryProvider` (normalized
  lookup), and records history.
- That Dart handler is already unit-tested (`test/providers/external_search_handler_test.dart`).

A deep link needs only to land a *word string* into that funnel. The funnel already does
cleaning, display, lookup, and history.

## What it should do
- Register a custom URL scheme `dpd` so that a link of the form `dpd://word/<word>` launches
  the app (cold start) or focuses it (warm launch) and looks up `<word>`.
- Canonical format: `dpd://word/<word>`, where `<word>` is percent-encoded. Examples:
  - `dpd://word/bhavana`
  - `dpd://word/dhamma`
  - `dpd://word/sa%E1%B9%85kh%C4%81ra` (saṅkhāra)
- Cold start (app not running): opens directly to search results for `<word>`.
- Warm launch (app in background): returns to the search screen, clears any pushed routes,
  and shows results for `<word>` — identical to today's share-intent warm-launch behavior.
- The word is cleaned by the existing `IntentService._clean()` before lookup, so stray
  characters from a malformed link are stripped just like share intents.

## Approach (minimal)
Two edits, both Android-side; **zero Dart changes**:

1. `android/app/src/main/AndroidManifest.xml` — add an `ACTION_VIEW` + `BROWSABLE`
   intent-filter to `MainActivity` matching `scheme="dpd"` `host="word"`. (`BROWSABLE` is
   what lets a browser link launch the app; `MainActivity` is already `singleTask` +
   `exported="true"`.)
2. `android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/MainActivity.kt` — extend
   `extractText(intent)` with an `ACTION_VIEW` branch that reads `intent.data`, takes the
   path segment after `/word/`, and returns it as the lookup string. The existing
   `getInitialText` / `onNewIntent` → `emitWord` plumbing carries it to Dart unchanged.

No new channel, no new provider, no new Dart code. The format contract for external sites is
documented in this spec and in the commit body.

## Assumptions & uncertainties
- **Scheme choice = custom scheme only** (confirmed with user). Verified App Links
  (`https://...` + `assetlinks.json`) are deferred — they need a domain the user controls
  and a hosted verification file. A custom scheme shows a one-time "open with" prompt on
  Android 11+ until the user chooses DPD; acceptable for v1.
- **Android only** for v1. The app is Android-first per `tech.md`. iOS would register the
  same `dpd` scheme via `Info.plist` `CFBundleURLSchemes`; desktop (Linux/macOS/Windows)
  does not receive web deep links the same way and is out of scope. Noted as follow-ups.
- **Path format `dpd://word/<word>`** is the canonical form. It is a public contract — once
  dhamma.gift builds against it, it is frozen. The query-param form (`dpd://word?w=<word>`)
  is deliberately NOT supported in v1 to keep the parser strict and predictable; easy to add
  later if a site needs it.
- **No new automated test.** There is no Kotlin test infrastructure in this project, and the
  word-extraction is a few lines of platform code. The Dart handler the link feeds is
  already covered by `external_search_handler_test.dart`. Verification is manual via `adb`
  (cold + warm), matching how the existing share-intent path is verified.
- **URL decoding.** Android's `Uri.getLastPathSegment()` returns the decoded segment, but
  the implementer must confirm this with a multi-byte Pāḷi test (e.g. saṅkhāra) since that
  is the failure-prone case. Trailing-slash and empty-path forms must degrade gracefully
  (return `null` → dropped by `_clean()`).
- **`+` is not decoded to space.** `lastPathSegment` does plain percent-decoding, not
  form-encoding decoding — a literal `+` in the path is passed through as-is, not turned into
  a space. If an external site encodes a multi-word query with `+` (form-style) instead of
  `%20`, the `+` survives into the word string and is then stripped by `_clean()`'s
  disallowed-character filter, silently concatenating the two halves (e.g. `an+atta` →
  `anatta`) instead of failing loudly. Out of scope to fix — v1 is single-headword lookups
  only (see "What's not included") — but documented here as a known non-goal rather than an
  unconsidered gap.

## Constraints
- Reuse the existing intent funnel — do not fork a parallel deep-link path. (AGENTS.md
  "External Entry Points" and "Two Search Paths".)
- Add deep links to AGENTS.md's "External Entry Points" list itself, alongside share
  intents, lookup intents, and CLI args — it's a fourth entry point of the same kind, and
  that section is what future reviewers check.
- No new Dart dependency.
- `_clean()` already runs on the extracted word, so the same sanitization that protects
  share intents protects deep links — do not bypass it.
- Respect the existing `singleTask` + `onNewIntent` behavior so warm launches do not stack
  duplicate activities.

## How we'll know it's done
- `adb shell am start -a android.intent.action.VIEW -d 'dpd://word/bhavana'` with the app
  **closed** opens DPD directly showing bhavana results.
- Same command with the app **open** (in background) returns to search and shows bhavana
  results, with no duplicate activity in recents.
- A multi-byte Pāḷi word link `dpd://word/sa%E1%B9%85kh%C4%81ra` decodes to saṅkhāra and
  shows correct results (no mojibake / no "no results").
- A malformed/empty link (`dpd://word/`) does not crash — it is dropped by `_clean()` and
  the app opens to a normal empty search, same as a blank share.
- A web `<a href="dpd://word/bhavana">` link tapped from a browser launches DPD.

## What's not included
- Verified App Links (`https://` scheme + `assetlinks.json`). Follow-up if/when a domain is
  available.
- iOS Universal Links / custom-scheme registration. Follow-up when iOS becomes a priority.
- Desktop (Linux/macOS/Windows) URL handling.
- Query-parameter form of the link (`?word=` / `?w=`). Add later only if a site needs it.
- A headword-ID deep link (jump straight to a full entry by id). The lookup-by-word form is
  what dhamma.gift needs; id-based is a separate, later feature.
- In-app UI to "copy deep link" for the current word. (Nice-to-have, not requested.)
