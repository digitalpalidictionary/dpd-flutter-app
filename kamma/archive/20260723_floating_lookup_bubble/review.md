# Review: DPD floating lookup bubble

**Verdict: PASSED** (2026-07-24)

Reviewed by two independent passes run in parallel — an adversarial from-scratch
correctness review (subagent) and CodeRabbit (`coderabbit review --agent --base main
--type uncommitted`) — plus on-device testing confirmed by the user.

## Objective
A system-wide floating "dpd" bubble drawn by a custom Android AccessibilityService.
Highlighting a word in any app and tapping the bubble looks it up in DPD via the
existing external-search funnel. Two-tier capture (passive text-selection event; else
click the app's Copy button + read clipboard). Plus a shared settings/header toggle,
native theme colours, position + on/off persistence, and a code-drawn `DpdLogo` that
replaces the SVG logo assets.

## Files changed
- android/app/src/main/AndroidManifest.xml — registered the accessibility service
- android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/MainActivity.kt — bubble MethodChannel, word routing, clipboard read, lifecycle show/hide, colour prefs
- android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/SelectionAccessibilityService.kt (new) — overlay bubble, two-tier capture, drag/position, themed "dpd" label
- android/app/src/main/res/xml/selection_accessibility_config.xml (new)
- lib/services/bubble_service.dart (new) — MethodChannel client
- lib/widgets/bubble_toggle.dart (new) — shared bubbleOnProvider, setBubbleOn, consent dialog
- lib/widgets/dpd_logo.dart (new) — code-drawn brand mark with auto-contrast label
- lib/widgets/settings_panel.dart — settings toggle
- lib/screens/search_screen.dart — header toggle, header logo swap
- lib/screens/download_screen.dart — splash logo swap

## Findings & fixes applied
1. **[MEDIUM] Clipboard crash** — `getItemAt(0)` could throw `IndexOutOfBounds` on a
   non-null but empty clip (failed Tier-2 copy), crashing from `postDelayed`.
   **Fixed:** guard on `itemCount == 0` in `MainActivity.readClipboardAndEmit`.
2. **[MEDIUM/major] Two toggles held independent state** (both reviewers) — header and
   settings controls could disagree until an app resume.
   **Fixed:** hoisted to a shared `bubbleOnProvider`; both watch/write it; displayed
   state = on/off intent AND accessibility permission granted; re-syncs on resume.

## Verified correct (reviewers probed, no defect)
- ARGB Long→`toInt()` truncation correct for full-alpha colours.
- ComponentName enabled-check handles the `.debug` applicationId suffix.
- No double-emit / no stale intent re-processing (extras removed synchronously).
- Bubble text uses the same `_clean` path as share/PROCESS_TEXT — no path divergence.
- Colour prefs persist before first paint — race-free.

## Test evidence
User tested on a real Android device and confirmed: lookup works in all apps, PDFs,
and websites (Tier 1 and Tier 2); bubble stays while switching apps and closes when the
app is closed; both toggles stay in sync; theme colours and centring correct.

## Post-review changes (user-directed, re-verified on device)
- Bubble tied to app lifecycle (show on resume, hide on close).
- Bubble "dpd" label centred (`includeFontPadding=false`).
- Header icon set to `touch_app` (user's choice).
- `DpdLogo` code widget replaces SVG logo in header + splash; `flutter_svg` now unused.
- Standalone POC (`../dpd-floating-poc`) and its `poc-install` justfile recipe deleted.
