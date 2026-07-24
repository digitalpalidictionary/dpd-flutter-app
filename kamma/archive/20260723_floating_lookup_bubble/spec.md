# Spec: DPD floating lookup bubble (system-wide highlight → dictionary)

## Overview

A persistent, draggable floating "DPD" button, always available over every app.
When the user highlights a word in any app and taps the bubble, that word is sent
to the DPD dictionary and looked up. This is the DictTango-style feature the user
originally requested: *"a permanent floating button overlaid on the screen … whenever
it gets clicked, whatever text is highlighted gets sent to the dictionary."*

The mechanism below was **proven end-to-end on a real Android 16 device** in a
standalone throwaway POC at `../dpd-floating-poc` (sibling of this repo). That POC is
the working blueprint — its Kotlin files are copy-adaptable. Full research history is
also in the project memory note `floating_button_poc.md`.

**Android only.** (iOS has no equivalent capability; not in scope.)

## Background: how it works (the proven mechanism)

Two separate problems, both solved:

**1. Draw a persistent floating button over all apps** — via a custom Android
`AccessibilityService` that adds a `TYPE_ACCESSIBILITY_OVERLAY` window. This needs
**NO `SYSTEM_ALERT_WINDOW` ("draw over other apps") permission** — the accessibility
grant itself authorizes the overlay. (We deliberately do NOT use
`flutter_overlay_window` / `SYSTEM_ALERT_WINDOW`: it fought Android 14+/16's
foreground-service and background-activity-launch rules and produced no usable window.)

**2. Get the highlighted word on tap** — a two-tier capture strategy:

- **Tier 1 — passive selection (WebView / native selectable text):** the service
  subscribes to `TYPE_VIEW_TEXT_SELECTION_CHANGED` and reads the selected substring
  from **the EVENT's `getFromIndex()` / `getToIndex()` + `getText()`** — NOT
  `node.textSelectionStart/End`, which returns `-1` for WebView. Store the last word +
  a timestamp. On bubble tap, if a selection fired within ~8s, use that word.
  **Covers:** Chrome, SuttaCentral and any website, **AnkiDroid** (its cards are a
  WebView), and native selectable `TextView`s. Verified: captured `needing`,
  `sāvakehi`, `abhiññātehi`, `Mahāmoggallāna`, `pacāpetvā`, `bhuñjeyya` with full
  Pāḷi diacritics, zero manual copy.

- **Tier 2 — click-Copy fallback (Flutter / canvas / system-toolbar apps):** if no
  fresh passive selection exists, traverse **all windows**
  (`rootInActiveWindow` + `getWindows()`) for a visible **"Copy"** button and
  `performAction(ACTION_CLICK)` on it — this clicks the *app's own* Copy button for
  the user (no manual copy) — then read the clipboard.
  **Covers:** the **Tipiṭaka Pāḷi Reader** (Flutter; fires no selection event, but its
  in-window selection toolbar Copy button is clickable — verified: captured `aṭṭhāsi`,
  `upasaṅkamitvā`, and it works even with TPR's own "copy to clipboard" setting OFF)
  and apps whose Copy lives in the system floating toolbar.

**Routing into DPD:** the clipboard can only be read by the *foreground* app on
Android 10+, so on bubble tap the service **launches/foregrounds the DPD app**
(`MainActivity`, with `FLAG_ACTIVITY_REORDER_TO_FRONT | NEW_TASK | SINGLE_TOP`); DPD
then reads the clipboard (with a ~250–400 ms delay for the copy to settle) and/or
receives the passive-selection word over a platform channel. The word is fed into the
**existing search seam** `ExternalSearchHandler.apply(text)`
(`lib/providers/search_provider.dart`, via `externalSearchHandlerProvider`) — the same
funnel the share intent and PROCESS_TEXT already use.

## What it should do

1. Add a **custom AccessibilityService** (Kotlin) to the DPD Android app that draws a
   draggable, persistent floating bubble over all apps while the service is enabled. The
   bubble matches the in-app **header logo style**: a round circle in the **theme primary
   colour** with a **"DPD" label in the theme on-primary colour** (user: "match the style of
   the logo in the top left… adjusted to light/dark/theme colour" → simplified to "a simple
   circle in theme colour with suitable text colour saying DPD"). Both colours are pushed
   from Flutter over the channel (`primary`/`onPrimary` as ARGB ints) and persisted, so the
   bubble tracks light/dark/scheme; amber `#C27F29` + white are only the pre-push fallback.
   It remembers and reopens at its last dragged position.
2. On bubble tap, capture the highlighted word via the two-tier strategy above, then
   open DPD in the foreground showing the lookup result for that word.
3. Provide, in DPD's settings, a **single On/Off toggle** for the bubble — identical in
   form to every other setting (the user explicitly rejected a separate onboarding
   *screen* and a multi-control tile: "a simple toggle like all the rest"). Turning it On
   the first time, while the accessibility service is not yet enabled, shows a **simple
   consent/disclosure dialog** that explains what the service does and reads, with a button
   to open Android's accessibility settings (this dialog is the Play-compliance prominent
   disclosure — see Constraints). After the permission is granted the toggle just stays On.
4. The toggle both reflects and controls the bubble.
   **The bubble is tied to the DPD app being open** (2026-07-24, per user: "when the app
   closes the bubble must also close"): `MainActivity` shows it in `onResume` (if the on/off
   intent pref is set) and removes it in `onDestroy` when the app is finishing/swiped away.
   It stays visible over other apps while DPD is merely *backgrounded* (that is the whole
   point); it disappears only when DPD is actually closed, and returns when reopened. It is
   NOT auto-shown by the accessibility service on connect/boot.
   **Both controls share one state** (`bubbleOnProvider`, 2026-07-24, per user: "of course
   setting and header must be in sync… show the state") — the settings toggle and the header
   button both watch/write it, so they always agree. The displayed state reflects reality:
   the on/off intent (`dpd_bubble`/`visible` SharedPref) AND the accessibility permission
   actually being granted; it re-syncs on app resume. Both call one shared
   `setBubbleOn()`/`applyBubbleToggle()` (`lib/widgets/bubble_toggle.dart`), so behaviour and
   the first-time consent dialog are identical from either entry point.
   **The same control also lives in the search header** (per user: "both, so users can find
   it either way") — a `touch_app`/`touch_app_outlined` toggle icon next to Settings
   (Android only; icon chosen by user).
   **The bubble remembers its last dragged position** (per user) — x/y persisted to the
   `dpd_bubble` SharedPref on drag-end and restored in `showButton()`. The "dpd" label is
   optically centred (`includeFontPadding=false`).
5. Keep DPD's existing complementary entry points working unchanged: the
   `ACTION_PROCESS_TEXT` selection-menu "DPD" item (`ProcessTextActivity`) and the
   `ACTION_SEND` share target. The bubble complements, does not replace, these.
6. **Logo as code, not asset (2026-07-24, per user).** A test (inkscape rasterise + pixel
   diff → 0.71/255, visually identical) proved `identity/logo/dpd-icon.svg` is simply the
   word "dpd" set in **Inter Bold** (already bundled via `GoogleFonts`) inside a circle. So a
   reusable `DpdLogo` widget (`lib/widgets/dpd_logo.dart`) renders it in code — any size, any
   theme, no SVG/mask. Its label **auto-contrasts** against the circle (black on light, white
   on dark — e.g. black on amber, not white) via `DpdLogo.contrastOn`. It replaces the SVG
   logo in the **header** and the **download/splash screen**, and the floating bubble uses the
   same lowercase-"dpd" + contrast styling. This is deliberately broader than the bubble
   feature: one themeable brand mark to reuse everywhere.

## Assumptions & uncertainties

- **Result presentation = open the full DPD app** (foreground) with the result, per the
  user's explicit earlier statement ("when the button is clicked it must switch to the
  DPD app"). A lightweight floating result popup that keeps the user in their reading app
  (DictTango-style) is a *possible future enhancement*, not Phase 1. **Confirm at
  `/kamma:2-do` if desired.**
- **Bubble visibility is tied to the DPD app being open** + a user toggle (revised
  2026-07-24). The on/off intent is persisted natively (`dpd_bubble`/`visible` SharedPref);
  the bubble is shown by `MainActivity.onResume` while the app runs and removed by
  `onDestroy` when it closes. It is deliberately NOT auto-shown on `onServiceConnected`, so
  after a reboot it appears only once DPD is opened again — matching "close app → close
  bubble".
- **"Copy" label match is English-only in the POC.** The real implementation should find
  the copy affordance more robustly — prefer a node whose action list contains
  `ACTION_COPY`, or match the localized copy label — so it works in non-English UIs.
  Needs verification per-locale.
- **Package name:** the debug build is `net.dpdict.dpd_flutter_app.debug`; release is
  `net.dpdict.dpd_flutter_app`. The `isAccessibilityEnabled()` component check must use
  the *runtime* `packageName`, compared via `ComponentName.unflattenFromString` (see
  Constraints).
- Existing native package path: `android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/`
  (contains `MainActivity.kt`, `ProcessTextActivity.kt`). Existing Dart seam:
  `lib/providers/search_provider.dart` (`ExternalSearchHandler.apply`,
  `externalSearchHandlerProvider`), `lib/services/intent_service.dart` (channels
  `net.dpdict.app/intent`, `net.dpdict.app/intent/stream`), `lib/app.dart` (initState
  subscribes to `IntentService.intentStream` → `apply`). These were confirmed earlier but
  should be re-read at implementation time.
- Whether DPD already has a settings screen to host the toggle/onboarding, or one must be
  added — verify in `lib/`.

## Constraints

- **Android clipboard rule (API 29+):** only the foreground app or the active IME can
  read the clipboard. The accessibility service itself CANNOT read it in the background —
  DPD must be foregrounded first, then read. (No accessibility exemption exists.)
- **Use `event.getFromIndex()/getToIndex()`**, never `node.textSelectionStart/End`
  (which is `-1` for WebView).
- **`isAccessibilityEnabled()` must compare via `ComponentName.unflattenFromString`** —
  Android stores the enabled-services setting in the short `pkg/.Class` form, so plain
  string equality against the fully-qualified name fails (the bug that made the POC's
  status wrongly show "OFF").
- **Android 12+ shows a "pasted from clipboard" toast** whenever an app reads the
  clipboard. Unavoidable for full reads via the Tier-2 path. Acceptable; note in UX.
- **Play Store accessibility policy:** using an `AccessibilityService` for a
  non-accessibility purpose requires a Play Console "accessibility use" declaration, a
  **prominent in-app disclosure**, and explicit user consent, or the app risks
  rejection/removal (enforcement tightened ~Jan 2026). The onboarding/consent screen
  (item 3) is a store-review requirement, not optional polish. During development DPD is
  sideloaded (self-updates via APK / `REQUEST_INSTALL_PACKAGES`), so this only bites at
  Play submission — but design it in now.
- Follow project rules in `AGENTS.md`: native Flutter widgets for DPD content, theme
  colours only (no hardcoded colours), reuse existing patterns, one-feature-one-commit,
  never commit without explicit "yes".

## How we'll know it's done

- Enabling the DPD accessibility service (via the in-app onboarding screen) shows a
  draggable "DPD" bubble over other apps.
- Highlighting a word in **Chrome / SuttaCentral** and tapping the bubble opens DPD with
  that word's entry. (Tier 1)
- Highlighting a word in **AnkiDroid** and tapping the bubble looks it up. (Tier 1)
- Highlighting a word in the **Tipiṭaka Pāḷi Reader** and tapping the bubble looks it up,
  with no manual copy and regardless of TPR's own copy setting. (Tier 2)
- Highlighting a word in a **PDF (Google Drive viewer)** and tapping the bubble looks it
  up. (Tier 2)
- The status indicator correctly reflects enabled/disabled (via the ComponentName fix).
- Existing PROCESS_TEXT "DPD" menu item and Share still work.

## What's not included (deferred / future phases)

- **Screenshot + OCR (ML Kit) for scanned/image PDFs** that have no text layer — the only
  content type not covered by the two tiers. A separate, heavier future phase; Pāḷi-
  diacritic OCR accuracy is untested. Note it, don't build it now.
- **Google Files PDF viewer** works only partially (its system-floating-toolbar Copy has a
  timing issue — captures the *previous* clipboard word). Treat as a known limitation; do
  not special-case it. Google Drive and other PDF viewers work.
- A floating **result popup** that keeps the user in their reading app (DictTango-style) —
  possible later; Phase 1 opens the DPD app.
- iOS.
- Localization of the "Copy" match beyond a reasonable robust approach (see Assumptions).
