# Spec — Chrome layout survives large system fonts

## Overview

A user asked for "an option to change the font size of menus and titles as well",
attaching a screenshot in which the settings panel is visibly mangled: the row
labels "Theme" and "Colour" are broken one letter per line, and the header title
wraps to two lines.

**The requested option already exists — it is the phone's own system font size.**
Investigation (see Verified facts) confirms the app applies no text-scale clamping
anywhere, so Android's display-font setting flows straight into every piece of UI
chrome. The screenshot is not the app ignoring the user's preference; it is the app
honouring it and then breaking its own layout.

Therefore this thread adds **no new setting**. It fixes the layout so a large system
font looks right.

## Verified facts

Established by reading the source, not assumed:

- `lib/widgets/content_text_scale.dart` is the only place in `lib/` that touches
  `textScaler` (verified by `grep -rn "textScaler|textScaleFactor" lib/`). It applies
  the `Results font size` setting as `TextScaler.linear(fontSize / 16.0)`.
- `ContentTextScale` is used at exactly three sites — `root_screen.dart:82`,
  `entry_screen.dart:79`, `search_screen.dart:751` — all of which wrap *results /
  entry content*, never chrome. The settings panel is therefore rendered at the raw
  OS text scale.
- `settingsProvider.fontSize` (`lib/providers/settings_provider.dart`) defaults to
  16.0, range 12–24 via the slider at `settings_panel.dart:84`. It is the
  "Results font size" control and is deliberately content-only.
- `lib/app.dart:184` `buildTextTheme` sets absolute sizes from `baseSize = 14.0`.
  There is no scale override at `MaterialApp` level.
- The breakage mechanism: `_buildSettingTile` (`settings_panel.dart:300`) renders
  `ListTile(title: Row([Flexible(Text(title)), help]), trailing: control)`.
  `ListTile` measures `trailing` at its intrinsic width first. The control is
  `CompactSegmented` (`lib/widgets/compact_segmented.dart`), whose inner `Row` is
  `mainAxisSize: MainAxisSize.min` and never shrinks. At a large text scale the
  control consumes nearly the whole row, the title's `Flexible` collapses to a few
  pixels, and `Text` wraps per character — exactly the "C-o-l-o-u-r" in the
  screenshot.
- Exhaustive sweep of affected call sites (`grep -rn "CompactSegmented" lib/` and
  `grep -rn "_buildSettingTile" lib/`) — four layout sites, no others:
  1. `settings_panel.dart:300` — shared `_buildSettingTile`, used by 17 tiles
     (lines 46, 58, 71, 84, 100, 118, 130, 143, 155, 167, 179, 191, 204, 216, 228,
     246, 258).
  2. `settings_panel.dart:487` — a **duplicate** `_buildSettingTile` private to
     `_BubbleTile`, used once at line 467.
  3. `settings_panel.dart:517` — `_HotkeyTile` builds a raw `ListTile` with the same
     title `Row` shape; trailing is a `Row` of `OutlinedButton` + `IconButton`.
  4. `dict_settings_widget.dart:81` — a raw `ListTile` in a reorderable list, with a
     `leading` reorder handle, a subtitle, and a `CompactSegmented` trailing.
- The header title (`search_screen.dart:531`) is already inside an `Expanded`, so it
  wraps to two lines rather than overflowing. It is not broken — it is merely large.
  The user has nonetheless asked for it to be capped to one line.
- `AGENTS.md` forbids UI tests for this app. Verification is therefore manual, on a
  real Android device.

## What it should do

1. **Settings rows reflow instead of colliding.** A label and its control share a line
   when they fit, and the control moves to its own full-width line when they do not.
   The decision is made by measuring the actual laid-out widths, not by comparing the
   text scale against a threshold.
2. **Wide controls never overflow.** A four-segment control (`nīla / sūriya / tiṇa /
   dhūma`) too wide for the row clamps to the available width and scrolls sideways,
   rather than being clipped or throwing a `RenderFlex overflowed`. Whether scrolling
   is good enough, or should become a vertical list of full-width options, is a
   judgement to settle from a screenshot.
3. **One shared tile.** The three hand-rolled copies of the tile shape collapse into a
   single reusable widget, so the fix lands once and cannot drift back apart. This is
   not gold-plating: without it the same fix has to be written four times.
4. **The logo keeps its whole label.** The `dpd` brand mark is drawn as a fixed-size
   circle with the letters set as text, so the system font scale grows the letters
   inside a circle that does not grow and clips them to `d`. The mark's proportions
   come from its `size`, so its label must opt out of text scaling. This is a
   pre-existing defect, unrelated to the tile change, found during verification.
5. **Header title stays on one line.** `Digital Pāḷi Dictionary` shrinks to fit the
   available width instead of wrapping, keeping the header a single compact row at
   any system font size.

## Constraints

- **No new user setting.** The OS already owns chrome font size.
- **No scale clamping.** Do not cap or override `MediaQuery.textScaler`. Overriding a
  user's accessibility setting to protect our layout is the wrong trade.
- **No text-scale threshold.** Layout must be decided by measurement. A tipping-point
  constant is not acceptable here: it needs per-device tuning, and being slightly
  wrong reintroduces the exact defect being fixed.
- **Zero visual change at normal text scale (1.0).** This must follow from geometry —
  at 1.0 the content is narrower than the row, so a reflow layout produces today's
  arrangement — not from a guarded branch around the old code path.
- `ContentTextScale` and the `Results font size` setting are untouched.
- Theme colours only, per `AGENTS.md` — no hardcoded `Colors.*`.
- No UI tests (`AGENTS.md`).

## How we'll know it's done

On a real Android device, with **system font size at its largest**:

- Every settings row shows its full label, wrapped by word if long, never by character.
- The Colour row's four segments are all reachable, by swiping the control sideways
  if they do not all fit.
- No yellow-and-black overflow stripes and no `RenderFlex overflowed` messages in the
  console while scrolling the whole settings panel top to bottom.
- The floating-bubble row, the Linux lookup-hotkey row, and the dictionary list rows
  all behave the same way as the main settings rows.
- The header shows `Digital Pāḷi Dictionary` on one line.
- The logo reads `dpd`, not `d`.

With **system font size at default**:

- Rows without a subtitle are pixel-identical to `main`, including the 1px separators
  between segments.
- The three rows that have a subtitle — every dictionary row, `Results font size`, and
  the Linux `Lookup hotkey` row — are **deliberately not** pixel-identical. Moving the
  control out of `ListTile`'s `trailing` slot and into `title` means it is now centred
  on the label's line rather than on the whole two-line tile, so it sits roughly 10dp
  higher. On the `Results font size` row this reads better (the number sits beside its
  label instead of floating over the slider); on a dictionary row the reorder handle
  stays centred on the whole tile and so no longer lines up with the Off/On control.
  Judge from a screenshot whether the handle misalignment is worth addressing.

## Assumptions & uncertainties

- **Unverified and load-bearing:** that `SingleChildScrollView` sizes itself to its
  child when the child is narrower than the incoming maximum, rather than expanding to
  fill. The whole design rests on this — if it expands, the control always claims the
  full width, every row reflows at every scale, and the zero-change-at-1.0 requirement
  breaks. This is checked first, before any widget code is written.
- Assumed a sideways-scrolling control is acceptable at the largest font sizes. It is
  never ragged and never overflows, but part of it is off-screen until swiped. The
  alternative — a vertical list of full-width options — looks more deliberate and has
  bigger tap targets, at the cost of needing the row to know it did not fit. Deferred
  until there is a screenshot to judge.
- Assumed the resulting mixed appearance is acceptable: two-option rows (Off/On,
  Classic/Compact) will still fit side by side even at the largest font, so only the
  wider rows reflow. This may read as inconsistent; forcing every row to reflow
  together is easy once it can be seen.
- Assumed the label `Row` needs `MainAxisSize.min` to work inside the reflow layout —
  a max-size `Row` would claim the full width and force the control onto a second line
  at every scale, silently breaking the zero-change-at-1.0 requirement.
- Assumed the reorderable dictionary list keeps working when its `ListTile` is
  replaced by a custom widget carrying the same `key`. To be confirmed by dragging a
  dictionary row during verification.
- Not verified whether any other chrome surface (history overlay, info popups,
  feedback footer) also breaks at large scale. Out of scope for this thread; worth a
  follow-up sweep.

## What's not included

- No "menu font size" setting, and no separate chrome-scale slider.
- No cap on how far chrome scales.
- No redesign of `CompactSegmented`'s appearance. It gains a horizontal scroll view so
  it can clamp instead of overflowing, but its normal-scale look is unchanged and no
  colours, radii, or paddings are altered. It has no wrapped or two-row state.
- No changes to results/entry content rendering.
- No audit of chrome surfaces beyond the settings panel and the header.
