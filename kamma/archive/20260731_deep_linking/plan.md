# Plan: Deep Linking (custom `dpd://` scheme)

## Architecture Decisions

- **Ride the existing intent funnel — no new channel, provider, or Dart code.**
  The whole point of the verify-gate read of `MainActivity.kt` + `IntentService` +
  `search_provider.dart` was that a deep link only needs to land a *word string* into the
  already-tested `extractText → getInitialText / intentStream → externalSearchHandlerProvider.apply()`
  path. Adding a parallel deep-link path would fork an entry point, which AGENTS.md
  ("External Entry Points", "Two Search Paths") explicitly forbids. So the entire change is
  Android-native: (a) declare the scheme, (b) teach `extractText()` to turn a `dpd://`
  VIEW intent into that word string. Dart is untouched.
- **Custom scheme `dpd`, host `word`, path carries the word** (`dpd://word/<word>`).
  User confirmed custom-scheme-only (no verified App Links). Host `word` namespaces cleanly,
  keeps the parser strict/predictable, and leaves room for other hosts later (e.g. an
  `entry` host for headword-id links) without colliding. The `BROWSABLE` category is what
  permits a *browser* link to launch the app — without it the scheme only works from `adb`
  / other apps, not the web, which would defeat the dhamma.gift use case.
- **Handle `ACTION_VIEW` inside `MainActivity`, not a new trampoline activity.**
  `MainActivity` is already `singleTask` + `exported="true"` and already owns the
  `onNewIntent`/`getInitialText` plumbing. A separate activity would need to forward the
  intent and re-immitate `ProcessTextActivity`'s trampoline dance — needless complexity for
  a one-word payload. Warm launches reuse the live instance via `onNewIntent`; cold launches
  carry the VIEW intent as the launch intent so `getInitialText()` picks it up.
- **Path-based, not query-param.** `<word>` lives in the path so `Uri.getLastPathSegment()`
  (which auto-decodes percent-encoding) is a one-liner. Query-param support is explicitly
  deferred (see spec "What's not included") — easy to add later without breaking the path
  form.
- **No new test; verify manually via `adb`.** No Kotlin test infra exists in this repo, the
  extraction is ~3 lines of platform code, and the Dart handler it feeds is already covered
  by `external_search_handler_test.dart`. Manual `adb` cold/warm/multi-byte checks mirror how
  the share-intent path is verified today.

---

## Phase 1 — Register the scheme and extract the word

- [x] **1.1 Add the deep-link intent-filter to `MainActivity`**
  - File: `android/app/src/main/AndroidManifest.xml`
  - Add a new `<intent-filter>` inside the existing `MainActivity` `<activity>` block
    (alongside the `MAIN`/`LAUNCHER` and `SEND` filters), *after* the `SEND` filter:
    ```xml
    <!-- Deep link: dpd://word/<word> opens DPD at that word -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="dpd" android:host="word"/>
    </intent-filter>
    ```
  - Do not modify `launchMode`, `exported`, or the other filters.
  - → verify: `flutter build apk --debug` succeeds. Then on a connected device/emulator after
    install: `adb shell cmd package resolve-activity --brief -a android.intent.action.VIEW -d 'dpd://word/test'`
    prints a component under `net.dpdict.dpd_flutter_app` (not "No activity found").

- [x] **1.2 Teach `extractText()` to handle `ACTION_VIEW`**
  - File: `android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/MainActivity.kt`
  - In `extractText(intent: Intent?): String?`, add an `Intent.ACTION_VIEW` arm to the
    existing `when (intent.action)`:
    ```kotlin
    Intent.ACTION_VIEW -> intent.data?.lastPathSegment?.trim()?.takeIf { it.isNotEmpty() }
    ```
  - `lastPathSegment` returns the decoded segment, so `dpd://word/sa%E1%B9%85kh%C4%81ra`
    yields `saṅkhāra`. For an empty/missing path (`dpd://word/`, `dpd://word`) it returns
    `null`, which means `_clean()`/the funnel drops it and the app opens to a normal empty
    search — no crash. Pāḷi words contain no `/`, so a single segment is always the whole
    word. Note: `lastPathSegment` does plain percent-decoding, not form-decoding — a literal
    `+` is passed through as-is (not turned into a space) and then stripped by `_clean()`,
    silently concatenating a `+`-joined multi-word query. Not a bug to fix here; v1 is
    single-headword links only (see spec "Assumptions & uncertainties").
  - Re-read the file from disk immediately before editing (shared-tree gate).
  - → verify: `flutter build apk --debug` succeeds. Then, with the app **fully closed**:
    `adb shell am start -a android.intent.action.VIEW -d 'dpd://word/bhavana'` opens DPD
    showing bhavana results (cold-start path through `getInitialText`).

- [x] **1.3 Document the `dpd://` scheme**
  - Pick the most fitting existing doc surface (check `README.md` and `kamma/tech.md` first;
    do not create a new file if an existing one fits). Add a short section, e.g.:
    > ### Deep links
    > External sites can open DPD at a word with a link of the form
    > `dpd://word/<word>` (percent-encode the word). Example: `dpd://word/bhavana`.
    > Android only for now; the app opens to search results for that word.
  - Also append a dated note to `kamma/tech.md` recording the scheme + that it rides the
    existing intent funnel (mirror the style of the other dated entries there).
  - Add deep links to AGENTS.md's "External Entry Points" list, alongside share intents,
    lookup intents, and CLI args — it's a fourth entry point of the same kind, and that's
    the section future reviewers check when auditing entry points.
  - → verify: the section renders correctly and names the exact `dpd://word/<word>` format
    the implementer of 1.1/1.2 actually wired up; AGENTS.md's entry-point list now names
    deep links too.

- [x] **1.4 End-of-phase verification matrix (manual, via `adb` + browser)**
  With the freshly built debug APK installed, confirm each case:
  1. **Cold, ASCII:** force-stop the app, then
     `adb shell am start -a android.intent.action.VIEW -d 'dpd://word/bhavana'` → opens to
     bhavana results. **PASS** — `resolve-activity` also confirmed the intent-filter resolves
     to `net.dpdict.dpd_flutter_app.debug/net.dpdict.dpd_flutter_app.MainActivity`.
  2. **Warm, ASCII:** leave the app open/backgrounded, re-run the same command → returns to
     search, shows bhavana results, and `adb shell dumpsys activity recents` shows no extra
     DPD task (single-instance behavior intact). **PASS** — only one DPD task in recents.
  3. **Cold, multi-byte:** force-stop, then
     `adb shell am start -a android.intent.action.VIEW -d 'dpd://word/sa%E1%B9%85kh%C4%81ra'`
     → decodes to saṅkhāra, correct results, no mojibake. **PASS**
  4. **Malformed/empty:** force-stop, then
     `adb shell am start -a android.intent.action.VIEW -d 'dpd://word/'` → app opens to a
     normal empty search, no crash. **PASS**
  5. **From a browser:** open a real webpage with `<a href="dpd://word/dhamma">link</a>` in
     Chrome and tap it → launches DPD at dhamma. **PASS** — verified via a local HTTP server
     + `adb reverse` serving a real `<a href>` link (a `data:`/`file://` URI could not be
     opened directly in Chrome; a real hosted page was needed to exercise `BROWSABLE`).
  - → verify: all five pass. All five passed on first try; no fixes needed.

## Simplicity check
This is a 2-file core change (manifest + 3-line Kotlin arm) that reuses an existing,
already-tested funnel. There is no Dart phase, no new channel, no new provider, no new test,
and no new dependency. One phase, four small tasks, one of which is pure docs. Nothing to
trim further without dropping required behavior.
