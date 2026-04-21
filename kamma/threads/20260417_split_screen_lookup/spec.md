# Split-Screen Dictionary Lookup

## Status: ABANDONED — approach failed

## Overview
When enabled via a setting, shared/selected text from other apps should open DPD
in Android split-screen mode instead of full-screen, so the user can read their
source text and the dictionary side by side.

---

## What was attempted and why it failed

The approach used `FLAG_ACTIVITY_LAUNCH_ADJACENT | FLAG_ACTIVITY_NEW_TASK |
FLAG_ACTIVITY_MULTIPLE_TASK | FLAG_ACTIVITY_NEW_DOCUMENT` from trampoline
activities (`ShareTextActivity`, `ProcessTextActivity`) to launch `MainActivity`
in the adjacent split-screen pane.

### What was built (all reverted by user)
- `Settings.splitScreenLookup` field + `setSplitScreenLookup()` in `settings_provider.dart`
- Split-screen toggle `SwitchListTile` in `settings_panel.dart` (Android-only)
- New `ShareTextActivity.kt` trampoline (moved ACTION_SEND from MainActivity)
- Updated `ProcessTextActivity.kt` to read split-screen pref and apply flags
- `TransparentTrampolineTheme` in `styles.xml` (needed a real window for LAUNCH_ADJACENT)
- Manifest: trampoline launch deferred to `onResume()` (window must be attached first)
- Manifest: `android:taskAffinity=""` on both trampolines

### Iteration history

| Attempt | Change | Result |
|---------|--------|--------|
| 1 | `singleTask` + `LAUNCH_ADJACENT \| NEW_TASK` | New task 7147 appeared in SIDE, immediately killed by `singleTask` routing via `onActivityRestartAttempt` |
| 2 | `singleTop` + `LAUNCH_ADJACENT \| NEW_TASK \| MULTIPLE_TASK` | No new task — existing task 4 moved to SIDE, "Malformed enter transition", collapsed |
| 3 | `singleTop` + added `FLAG_ACTIVITY_NEW_DOCUMENT` | Same as attempt 2 — `LAUNCH_SINGLE_TOP` reported, taskId=4 moved to SIDE, failed |
| 4 | Added `android:taskAffinity=""` to trampolines | No change — taskId=4 still targeted, `taskParent=4 rootTask=4` |
| 5 | `android:launchMode="standard"` on MainActivity | New tasks 7227/7228 created with `LAUNCH_MULTIPLE`, but still `taskParent=4 rootTask=4` → `onTaskVanished` immediately |

### Root cause
Android's `ShellSplitScreen` requires two independent **root tasks** to enter
split-screen. Every approach resulted in the new DPD task being nested under
the existing DPD root task (`taskParent=4 rootTask=4`). The split-screen
controller rejects nested tasks with "Malformed enter transition" and immediately
destroys them (`onTaskVanished`).

This nesting happens because both the trampoline and the target activity share
the same package. Even with `FLAG_ACTIVITY_MULTIPLE_TASK | FLAG_ACTIVITY_NEW_DOCUMENT`
and `taskAffinity=""` on the trampoline, Android nests the new task under the
existing root task for the same package.

The fundamental limitation: **you cannot use `FLAG_ACTIVITY_LAUNCH_ADJACENT` to
split-screen an app against its own existing instance** on Pixel/Android 14+.
The shell-side split-screen implementation rejects this.

---

## Future possibilities to investigate

### 1. Jetpack WindowManager — ActivityEmbedding (most promising)
`androidx.window:window` library provides `ActivityEmbeddingController` and
`SplitPairRule`. This is the official modern API for embedding activities
side-by-side within a single app. It doesn't use `LAUNCH_ADJACENT` — it works
at the window embedding layer. Requires `android:allowUntrustedActivityEmbedding`
in the manifest and testing on Android 12L+.

### 2. Floating overlay window
Use `TYPE_APPLICATION_OVERLAY` permission (`SYSTEM_ALERT_WINDOW`). User grants
it once, then lookups appear as a floating draggable window over any app. More
invasive UX but widely used (e.g. Samsung floating apps). Requires
`android.permission.SYSTEM_ALERT_WINDOW` and user to grant "Draw over other
apps" permission. Flutter plugin: `flutter_overlay_window`.

### 3. Bubble notification
Android 11+ `Notification.BubbleMetadata`. The lookup result appears as a chat
bubble icon that expands to a small floating panel. Native Android API, no
special permissions. Limited screen area (~1/3 screen). Complex to implement
with Flutter.

### 4. Document the manual split-screen UX
The simplest path: in the settings panel, instead of a toggle, add a note
explaining how to manually enter split-screen (long-press recent apps button,
tap the app icon in the title bar). No code changes, no fragile Android internals.

### 5. Picture-in-Picture (PiP)
Works for video-like content. Could show a minimal entry card in PiP. Very
constrained layout. Probably not suitable for a dictionary.

---

## What's not included (remains out of scope)
- Customizing split ratio (Android controls this).
- iOS support.
- Compact/popup-specific UI layout for dictionary results.
