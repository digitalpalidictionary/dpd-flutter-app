# Plan: DPD floating lookup bubble

See `spec.md` for the full proven mechanism, coverage, and constraints. The working
blueprint is the POC at `../dpd-floating-poc` (Kotlin: `SelectionAccessibilityService.kt`,
`MainActivity.kt`, `CaptureBus.kt`; plus `AndroidManifest.xml` service/config entries and
`res/xml/selection_accessibility_config.xml`). Research history: memory note
`floating_button_poc.md`.

## Architecture Decisions

1. **Custom `AccessibilityService` + `TYPE_ACCESSIBILITY_OVERLAY` button.** Not
   `flutter_overlay_window`/`SYSTEM_ALERT_WINDOW` (it fails on Android 14+/16). The
   accessibility grant authorizes the overlay, so no draw-over-apps permission is needed.
2. **Two-tier capture.** Tier 1 = passive `TYPE_VIEW_TEXT_SELECTION_CHANGED` read via
   `event.getFromIndex()/getToIndex()+getText()` (never `node.textSelectionStart/End`).
   Tier 2 = click the app's own "Copy" button across all windows, then read the clipboard.
3. **Reuse the existing external-search funnel.** The captured word is delivered into
   `ExternalSearchHandler.apply()` via the *existing* `IntentService` path: the service
   foregrounds `MainActivity`, which forwards the word to the existing eventSink
   (`net.dpdict.app/intent/stream`) exactly like `ProcessTextActivity` already does. No
   new Dart search plumbing — only a new native source of text into the same channel.
4. **Place native code in the existing package** `net.dpdict.dpd_flutter_app` beside
   `MainActivity.kt`/`ProcessTextActivity.kt`. Adapt the POC files; do not invent new
   patterns.
5. **Consent/disclosure is mandatory** (Play accessibility policy), not polish. Delivered as
   a **simple first-enable dialog** (not a separate screen) — the user rejected a dedicated
   onboarding screen in favour of a plain toggle.
6. **`isAccessibilityEnabled()` via `ComponentName.unflattenFromString`**, not string eq.
7. **Minimal-first:** Phase 1 opens the DPD app on tap (no floating result popup); OCR for
   image PDFs is out of scope. **Bubble on/off + last position ARE persisted** (native
   `dpd_bubble` SharedPref, re-applied in `onServiceConnected`) — added 2026-07-24 to make
   the single toggle meaningful; reboot persistence follows for free.

## Phases

### Phase 1 — Floating bubble appears via the accessibility service
- [x] Re-read the current native + Dart seams before editing: `MainActivity.kt`,
      `ProcessTextActivity.kt` under `android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/`,
      `AndroidManifest.xml`, `lib/services/intent_service.dart`,
      `lib/providers/search_provider.dart`, `lib/app.dart`. Confirm the channel names and
      `apply()` signature still match the spec.
      → verify: note the exact channel constants and `ExternalSearchHandler.apply` signature in the task before proceeding.
      **CONFIRMED (2026-07-24):**
      - Package: `net.dpdict.dpd_flutter_app`. Native files: `MainActivity.kt`, `ProcessTextActivity.kt`.
      - Intent method channel: `net.dpdict.app/intent` (`getInitialText`). Event/stream channel: `net.dpdict.app/intent/stream`.
        `MainActivity.onNewIntent` pushes via `eventSink?.success(text)`; `extractText` handles ACTION_SEND + ACTION_PROCESS_TEXT only.
      - Dart: `IntentService.intentStream` (broadcast on `net.dpdict.app/intent/stream`, cleaned via `_clean`) → `app.dart` initState listens (`!Platform.isLinux`) → `ref.read(externalSearchHandlerProvider).apply(text)`.
      - Signature: `void ExternalSearchHandler.apply(String text)` — sets `searchBarTextProvider` (display) + `searchQueryProvider` (normalized) + records history. Single String arg, void.
      - `res/xml/` currently holds only `open_filex_provider_paths.xml` (must add the accessibility config).
      - **Design (decision #3):** reuse the existing eventSink — the service foregrounds `MainActivity` carrying the word (Tier 1) / a clipboard flag (Tier 2); `MainActivity` forwards to `eventSink?.success(...)`. No `CaptureBus` (POC-only). Bubble brand colour `#C27F29` (kapila amber; native overlay has no Flutter theme access).
- [x] Add `SelectionAccessibilityService.kt` (adapt from POC): draws a draggable
      `TYPE_ACCESSIBILITY_OVERLAY` bubble — a **round "dpd" badge matching the header logo**:
      a fixed-56dp circular bold `TextView` whose circle uses the theme **primary** colour and
      whose lowercase "dpd" label uses an **auto-contrast** colour (black on light / white on
      dark — see the logo task), both pushed from Flutter and persisted (amber+white
      fallback). `showButton()`/`hideButton()`/`setColors()`;
      `instance` static handle. Register it in `AndroidManifest.xml` with
      `BIND_ACCESSIBILITY_SERVICE`, the accessibility intent-filter, and
      `res/xml/selection_accessibility_config.xml` (`typeViewTextSelectionChanged` +
      `flagRetrieveInteractiveWindows`, `canRetrieveWindowContent=true`).
      → verify: `flutter build apk --debug` succeeds; after enabling the service in Android
        settings and toggling it on, a draggable round DPD-logo bubble appears over other apps
        (`adb shell dumpsys window windows | rg CREATE_ACCESSIBILITY_OVERLAY`).
- [x] Add a `MethodChannel` `net.dpdict.app/bubble` with `isEnabled`
      (ComponentName-compared), `isBubbleOn`, `openAccessibilitySettings`, `showBubble`,
      `hideBubble` (the show/hide handlers also persist the `visible` SharedPref); wire into
      `MainActivity.configureFlutterEngine`. Dart client: `lib/services/bubble_service.dart`.
      → verify: driven from the Settings/header toggle (Phase 4), `isEnabled` returns the
        correct bool and `openAccessibilitySettings` opens the right settings page.
- [x] Phase-1 verification.
      → verify: bubble shows/hides on command; status reflects reality; no regression to
        existing launch/share/PROCESS_TEXT flows (`just android-debug-update`, smoke-test share + the "DPD" menu item).

### Phase 2 — Tap bubble → look up the highlighted word (Tier 1: WebView/native)
- [x] In `SelectionAccessibilityService`, subscribe to
      `TYPE_VIEW_TEXT_SELECTION_CHANGED`; extract the substring from
      `event.fromIndex/toIndex + event.text`; store `lastWord`+`lastWordAt`
      (`SystemClock.elapsedRealtime`).
      → verify: logcat shows the exact selected word (with Pāḷi diacritics) when selecting
        in Chrome/SuttaCentral.
- [x] On bubble tap: if `lastWord` is fresh (<~8s), foreground `MainActivity` and deliver
      the word into the existing `net.dpdict.app/intent/stream` eventSink (same path
      `ProcessTextActivity` uses) → `IntentService.intentStream` → `apply()`.
      Implemented via a `bubble_text` intent extra + a `pendingWord` buffer in
      `MainActivity` (flushed on stream `onListen` for cold start).
      → verify: highlight a word in SuttaCentral, tap bubble → DPD opens showing that
        entry.
- [x] Phase-2 verification across Tier-1 apps.
      → verify: Chrome, SuttaCentral, and AnkiDroid each look up the highlighted word on
        bubble tap.

### Phase 3 — Click-Copy fallback (Tier 2: Flutter/TPR, PDF viewers)
- [x] On bubble tap with no fresh selection: search `rootInActiveWindow` + all
      `getWindows()` roots for a "Copy" affordance (prefer a node whose action list
      contains `ACTION_COPY`; fall back to localized "Copy" label),
      `performAction(ACTION_CLICK)`, then foreground `MainActivity` with a
      "read clipboard" flag.
      → verify: logcat shows `copyBtnFound=true clicked=true` and the copied Pāḷi word for
        TPR.
- [x] `MainActivity` on resume with the flag reads the clipboard (~250–400 ms after the
      click) and forwards the text into the same eventSink → `apply()`.
      Implemented: `from_a11y_button` extra → `onResume`/`onNewIntent` → 250 ms delayed
      clipboard read → `emitWord`.
      → verify: highlight a word in the Tipiṭaka Pāḷi Reader, tap bubble → DPD opens with
        that word, no manual copy, TPR copy-setting OFF.
- [x] Phase-3 verification across Tier-2 apps.
      → verify: TPR and a Google Drive PDF each look up the highlighted word on bubble tap.

### Phase 4 — Onboarding/consent + settings toggle (Play compliance)
- [x] Add the bubble control to DPD's settings (native Flutter widgets, theme colours per
      `AGENTS.md`). **DESIGN CHANGE (2026-07-24, per user):** not a separate onboarding
      *screen* — a single **On/Off toggle** (`CompactSegmented`, identical to every other
      setting) labelled "Floating bubble". Turning it On the first time (service not yet
      enabled) shows a simple `AlertDialog` that discloses what the service does + reads,
      with an "Open settings" button; after the accessibility permission is granted the
      toggle just stays On. The disclosure dialog is the Play-compliance prominent
      disclosure. On/off intent persists natively (`dpd_bubble`/`visible` SharedPref); the
      service re-shows the bubble on reconnect. The toggle re-syncs on app resume
      (`didChangeAppLifecycleState`) so returning from settings reflects reality.
      → verify: toggle On (first time) prompts to enable accessibility; the button opens
        the correct settings page; after enabling, the bubble appears and the toggle
        reflects/controls it; disclosure text is clear and precedes enabling.
- [x] Add the **same toggle to the search header** (Android only, next to Settings). Both it
      and the settings toggle share **one state** (`bubbleOnProvider`) and one action
      (`setBubbleOn`/`applyBubbleToggle`, `lib/widgets/bubble_toggle.dart`), so they always
      agree; displayed state = intent (`visible` pref) AND `isEnabled`, re-synced on resume.
      Icon: `touch_app` (on) / `touch_app_outlined` (off). Persist and **restore the
      bubble's last dragged x/y position**.
      → verify: toggling either control updates both; header reflects state on resume;
        dragging the bubble then toggling off/on reopens it in the same place.
- [x] **Bubble lifecycle tied to the app** (per user "when the app closes the bubble must
      also close"): `MainActivity.onResume` shows it (if `visible` pref) while the app runs;
      `onDestroy` (isFinishing) removes it on close; removed the `onServiceConnected`
      auto-show. Bubble stays over other apps while DPD is backgrounded, gone when closed,
      returns on reopen. Also centred the "dpd" label (`includeFontPadding=false`).
      → verify: bubble stays when switching to another app; disappears when DPD is swiped
        from recents; reappears when DPD is reopened; label looks centred.
- [x] **Logo as code (`lib/widgets/dpd_logo.dart`).** Proven (inkscape rasterise + pixel
      diff, 0.71/255) that `identity/logo/dpd-icon.svg` is just "dpd" in **Inter Bold** inside
      a circle — so render it as a widget (`DpdLogo{size, filled, circleColor, textColor}`),
      no SVG/mask. Label auto-contrasts via `DpdLogo.contrastOn` (black on light circles,
      white on dark — e.g. **black on amber**, per user; `ThemeData.estimateBrightnessForColor`,
      threshold 0.15). Replace the SVG logo everywhere in app code:
      **header** (`search_screen.dart`, was `Stack(Container+dpd-logo-mask.svg)`) and the
      **download/splash screen** (`download_screen.dart`, was `dpd-logo(-dark).svg`) — both now
      `DpdLogo(size:…)`, themed to `colorScheme.primary`. The **bubble** label is lowercase
      "dpd" (bold) and uses the same contrast colour (was `onPrimary`). `flutter_svg` import
      dropped from both screens; the `dpd-logo*.svg` assets are now unused by app code.
      NOTE: the splash logo changes from fixed brand-blue (`#00b2ff`) to the theme primary —
      pass `circleColor: const Color(0xFF00B2FF)` to pin it back if undesired.
      → verify: header + splash show the themed "dpd" circle; text is legibly contrasted in
        every theme/brightness (black on amber); bubble matches.
- [x] Phase-4 verification (Play-readiness).
      → verify: fresh-enable flow from onboarding works; disclosure text is prominent and
        precedes enabling; re-reading the flow, it would satisfy a Play accessibility-use
        disclosure. Full smoke test of all Tier-1 + Tier-2 apps end-to-end.

## Deferred (not this thread)
- Screenshot + ML Kit OCR for scanned/image PDFs (untested Pāḷi-diacritic accuracy).
- Floating result popup that keeps the user in the reading app (DictTango-style).
- Google Files PDF timing quirk (known limitation).

## Implemented beyond the original minimal scope (2026-07-24)
- Bubble on/off + last dragged position persisted natively (`dpd_bubble` SharedPref). The
  bubble is tied to the app being open (shown in `onResume`, removed in `onDestroy`), not
  auto-shown on service connect — so "close app → close bubble".
- Second entry point: search-header toggle (`touch_app`) sharing one `bubbleOnProvider`
  state and `setBubbleOn()`/`applyBubbleToggle()` with the settings toggle, so they stay in
  sync and show the true state (intent AND permission granted).
- Themed bubble: round "dpd" badge in the theme primary + auto-contrast text, matching the
  header logo; colours pushed from Flutter (`showBubble{bg,text}` / `setBubbleColor`) and
  recoloured live on theme change via the header button's `didChangeDependencies`.
- `DpdLogo` code widget replaces the `dpd-logo*.svg` assets in the header and splash screen;
  proven pixel-identical to the brand SVG. Reusable at any size/theme; text auto-contrasts.
