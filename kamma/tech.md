# Tech Notes

## Tools & Platforms
This project is a Flutter and Dart app that uses SQLite through Drift and Riverpod for state management. Android is the first priority, and the project is intended to support all major operating systems over time, including mobile, desktop, and web targets already present in the codebase.

## Who This Is For
This app is for monastics, scholars, students, and meditators interested in ancient Buddhist texts.

## Constraints
The main priority is fast startup, fast search, and reliable self-updates for both the app and the database. New work should support those goals rather than slow them down.

## Resources
The project already has an existing Flutter codebase, platform scaffolding, tests, release automation, and a sibling `dpd-db` repository used for database work.

## What The Output Looks Like
The output is a fast dictionary app, starting with Android first, that gives users access to the latest DPD database and related Pali and Sanskrit dictionaries, with broader operating system support over time.

## Transliteration (2026-04-12)
Input transliteration uses a custom stack imported from the sibling `../tipitaka-pali-reader` repo (`lib/utils/pali_transliterator/`). Script detection and script-to-Roman conversion cover all major Buddhist scripts (Sinhala, Devanagari, Thai, Myanmar, Khmer, Bengali, and more). Roman input returns unchanged immediately. Velthuis sequences (aa→ā, .t→ṭ, etc.) convert live in the text field. All other script normalization happens only for DB lookup without overwriting the user's typed script. A `searchBarTextProvider` (nullable `String?`) lets intent/share entry points set the original-script display text separately from the romanized lookup query — it is cleared after one use by the search screen listener.

## Search Performance (2026-04-05)
The `lookup` table in the mobile DB uses `lookup_key` as a PRIMARY KEY (created by `mobile_exporter.py`). This provides O(1) exact lookups. Partial and fuzzy searches use range queries (`>=` and `<`) instead of `LIKE` to leverage the B-tree index. Benchmarks against the full 860MB DB (1.27M lookup entries):
- Exact match: ~50μs
- Partial match: 200-250μs
- Fuzzy match: 75-90μs

## Fuzzy Result Ranking (2026-08-21)
`fuzzyCloseness()` (`lib/utils/fuzzy_rank.dart`) scores a fuzzy candidate as
`tier*1000 + lengthDelta`: tier 0 when the candidate's `fuzzy_key` equals the
query's exactly (a diacritic/aspirate/doubled-consonant-only difference),
tier 1 for a mere prefix match; length delta breaks ties within a tier. Used
in three places that must not drift apart: `DpdDao.searchFuzzy` (main-screen
Fuzzy tier), `DpdDao.searchFuzzyExact` (promotes a tier-0 match into the Exact
tier via `exactResultsProvider`, only when there's no literal exact hit — this
outranks a merely coincidental literal-prefix match `searchPartial` can turn
up via Pāḷi sandhi liaison), and `DpdDao.searchFuzzyExactKeyMatches` (the
autocomplete dropdown's tier-0 rescue, since its headword-only index can miss
an inflected form whose own collapsed key is longer than the base lemma's).
`_updateAutocomplete` in `search_screen.dart` runs the dropdown rescue after
tier 1's synchronous paint so it can only upgrade the overlay, never delay it.

## Change Log Asset (2026-04-12)
The in-app change log is generated at build time from local git tags and commit subjects by `tool/generate_changelog.dart`, which writes `assets/help/changelog.json`. Standard local build/run Just recipes and `.github/workflows/release.yml` regenerate that asset before packaging so the shipped app never depends on runtime git access or GitHub API calls.

## Floating Lookup Bubble (Android, 2026-07-24)
Android-only system-wide lookup. A custom `AccessibilityService`
(`SelectionAccessibilityService.kt`) draws a `TYPE_ACCESSIBILITY_OVERLAY` "dpd" bubble over
all apps — no `SYSTEM_ALERT_WINDOW` needed; the accessibility grant authorises the overlay.
Two-tier word capture: Tier 1 reads the passive `TYPE_VIEW_TEXT_SELECTION_CHANGED` event
(`fromIndex/toIndex + text`, never `node.textSelectionStart/End`); Tier 2 clicks the app's
own Copy button across all windows then reads the clipboard once DPD is foregrounded. The
captured word is routed through the *existing* `net.dpdict.app/intent/stream` eventSink →
`ExternalSearchHandler.apply()`, the same funnel as share/PROCESS_TEXT (no new Dart search
plumbing). Controlled by a shared `bubbleOnProvider` (settings toggle + header `touch_app`
button); on/off + colour + position persist in the `dpd_bubble` SharedPref. Bubble is tied
to the app being open (shown in `MainActivity.onResume`, removed in `onDestroy`). Uses a
custom `MethodChannel` `net.dpdict.app/bubble`. Play compliance: a first-enable consent
dialog discloses the accessibility use (required, not optional). iOS has no equivalent — out
of scope.

## Brand Logo As Code (2026-07-24)
`lib/widgets/dpd_logo.dart` renders the DPD mark ("dpd" in Inter Bold inside a circle) purely
as a widget — verified pixel-identical to `identity/logo/dpd-icon.svg`. Scales to any size,
tints to any theme, and auto-contrasts its label (black on light circles, white on dark). It
replaced the `dpd-logo*.svg` usages in the header and download/splash screen; `flutter_svg` is
no longer referenced by app code. Reuse `DpdLogo` for any future logo placement rather than
adding SVG assets.

## Autocomplete Dropdown Fallback Tiers (2026-07-26)
The suggestion dropdown under the search box tries three sources in order, each
only when the one above finds nothing: (1) the in-memory headword/root/family
index (`searchIndexProvider`), (2) enabled external dictionaries
(`searchDictWordsPrefix`), (3) the DPD lookup table as last resort
(`searchLookupKeysPrefix`). Tiers 2-3 match on exact prefix only — never
`fuzzy_key`/`word_fuzzy` — so no diacritic/aspirate/double-consonant folding
happens in the dropdown; that stays exclusive to search results and the
closest-matches screen. Sutta codes are stored uppercase (`DN1.1`), so any
lookup-table range query on a query containing a digit must also widen to the
uppercase range, matching `searchExact`/`searchPartial`/`searchClosestMatches`.

Async debounced UI updates that can dismiss/reopen an overlay (autocomplete,
any future similar widget) need a monotonic generation counter, not just timer
cancellation — cancelling a `Timer` only stops it from firing, it cannot stop
an already-running `async` body from resuming after the user has moved on
(committed a search, cleared the field, navigated away). Bump the counter at
every such action; capture it once before the first `await`; abandon the
result on mismatch.

**DB path pitfall:** `../dpd-db/dpd-mobile.db` and
`../dpd-db/exporter/mobile/dpd-mobile.db` are both zero-byte placeholders.
The real, current exported mobile DB (all 6 dictionaries) is
`../dpd-db/exporter/share/dpd-mobile.db` (`tools/paths.py:259`), produced by
`just export-mobile`. Never measure or benchmark against the placeholders.

## Dictionary Short Names In Summary (2026-07-27)
The search summary shows one row per external dictionary with an exact match, using a short one-word abbreviation (`dictShortName()` in `lib/providers/dict_provider.dart`) rather than `dict_meta.name`, which carries CC attribution text up to 58 characters. Adding a new external dictionary (see "External Dictionaries & English WordNet" below) needs an entry in that map too, or it falls back to a capitalised `dict_id`.

## External Dictionaries & English WordNet (2026-07-11)
External (non-DPD) dictionaries are not app code: the app auto-discovers any dictionary present in the mobile DB's `dict_meta`/`dict_entries` tables (built by `../dpd-db/exporter/mobile/mobile_exporter.py`) and renders (`flutter_widget_from_html`), searches, and toggles it with no Flutter changes. Open English WordNet (English–English, `dict_id = "wordnet"`, CC BY 4.0) is included this way. Attribution for CC-licensed dictionaries must live in `dict_meta.name` (shown in the UI) — the app never renders `dict_meta.author`. Inclusion is gated by a `--wordnet` exporter flag: local `just build-db` passes it (default on), while dpd-db's `mobile_release.yml` gates it behind a `workflow_dispatch` input (default off), so the public released DB omits it unless explicitly requested. The source data is generated once by `../dpd-db/resources/other-dictionaries/dictionaries/wordnet/wordnet_to_json.py` (uses the `wn` library, build-time only) and committed as `wordnet.tar.zst`; `other-dictionaries` is a git submodule, so CI needs the submodule commit pushed and its pointer bumped before `include_wordnet=true` works.

## Deep Links (2026-07-31)
Android registers a custom `dpd://word/<word>` scheme (`BROWSABLE` intent-filter on `MainActivity` in `AndroidManifest.xml`) so external sites (e.g. dhamma.gift) can link straight to a word. It rides the existing external-entry funnel rather than forking a new one: `MainActivity.extractText()` gained an `Intent.ACTION_VIEW` arm that reads `intent.data?.lastPathSegment` (auto percent-decoded) and returns it as the lookup string, same as `ACTION_SEND`/`ACTION_PROCESS_TEXT` already did. From there it's unchanged — `getInitialText`/`onNewIntent` → `emitWord` → `intentStream` → `IntentService._clean()` → `externalSearchHandlerProvider.apply()`. No new Dart code, no new channel. `+` in the path is not form-decoded to a space (plain percent-decoding only) — out of scope for v1, which is single-headword links only.
