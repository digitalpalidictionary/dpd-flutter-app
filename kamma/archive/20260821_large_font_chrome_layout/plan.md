# Plan — Chrome layout survives large system fonts

Spec: `spec.md` in this directory. Read it first.

## Architecture Decisions

- **No new setting, no scale clamp.** The OS font-size slider already drives chrome.
  The defect is layout, not a missing control.
- **No text-scale threshold.** Layout is decided by measuring whether things fit, so
  the normal-scale arrangement falls out of the geometry rather than from a guarded
  branch around the old code path.
- **One shared widget, new file: `lib/widgets/setting_tile.dart`.** Four sites
  hand-roll the same tile shape, one of them a literal copy-paste
  (`settings_panel.dart:300` vs `:487`). Fixing in place means writing the same fix
  four times and leaving the duplication that caused the drift.
- **`ListTile` is kept, with a `Wrap` in its `title` slot and no `trailing`.** `Wrap`
  supplies the fit-or-reflow decision; `ListTile` keeps supplying padding, minimum
  height, and subtitle typography, so none of that has to be reimplemented. With
  `trailing: null` the title slot spans the full content width, so a right-aligned
  child lands on the same x as today's `trailing`.
- **The control gets a horizontal scroll view rather than wrapping its segments.** This
  rests on `SingleChildScrollView` sizing itself to `constraints.constrain(childSize)`
  — it takes its child's width when the child is narrower than the incoming maximum,
  and only clamps and scrolls when the child is wider. **This must be verified before
  it is relied on** (task 1). If it instead expands to fill, the control would always
  claim the full width, force an unconditional reflow, and break the
  zero-change-at-1.0 requirement.
- **Segments are not wrapped into a grid.** A 2+2 grid would need every segment to be
  the same width to look tidy, and equalising widths changes the control's appearance
  at normal scale. Scrolling keeps normal scale untouched.
- **`IntrinsicHeight` + `VerticalDivider` stay as they are.** They only needed removing
  for the abandoned wrapped-segments design. `CompactSegmented` is still edited — it
  gains the scroll view — but leaving its inner layout alone keeps the edit to one
  wrapper on a widget used at 18 call sites.
- **Header uses `FittedBox(fit: BoxFit.scaleDown)`.** Shrinks to fit, never enlarges,
  keeps the whole title legible rather than ellipsising it away.
- **Verification is by throwaway harness, not committed tests.** `AGENTS.md` forbids UI
  tests in this app. A scratch harness that pumps the panel at several text scales is a
  development check and must not be committed.

## Findings (Phase 1, recorded 2026-08-21)

- **`SingleChildScrollView` sizes to its child.** Probe: incoming `maxWidth` 360, child
  80 wide → scroll view measured 80.0, not 360. The design's load-bearing assumption
  holds, so the control keeps its own width until it stops fitting.
- **The old shape leaves render boxes unlaid-out.** With
  `ListTile(title: Row([Flexible(Text)]), trailing: control)` and a control wider than
  the row, `getSize` on the tile throws `RenderBox was not laid out` and the label's
  `RenderParagraph` reports `NEEDS-LAYOUT`. The label is not merely squashed — it is
  skipped. This is the screenshot's per-character wrapping, confirmed at the render
  layer rather than inferred.
- **The new shape lays out cleanly at every scale.** `SettingTile` at 1.0 / 1.15 / 1.3 /
  1.5 / 2.0 produced `errors=none` at every step, with the label always laid out and
  tile height growing smoothly (100 → 128 in probe units).
- **Absolute widths from widget tests are not usable.** No fonts are bundled — the app
  fetches Inter and Noto Serif through `google_fonts` at runtime — so widget tests fall
  back to Flutter's test font, which renders every glyph as a full-size square. Measured
  text is therefore much wider than reality (the four-segment Colour control measured
  367 units at scale 1.0, against roughly 230dp expected in the real app). Consequence:
  **the exact scale at which a given row starts to reflow cannot be determined from
  tests and must be seen in the running app.** Only the presence or absence of layout
  errors is trustworthy from the probe.
- Baseline `flutter analyze`: 51 issues, all `info`, all pre-existing in
  `lib/utils/pali_transliterator/**` and `lib/utils/search_timing.dart`. Post-change:
  51. No new issues.

## Phase 1 — Establish the layout facts

- [x] Write a throwaway harness in the scratchpad that pumps a `SingleChildScrollView`
      (horizontal) with a narrow child under a wide `BoxConstraints`, and reports the
      resulting width. Confirm it equals the child's width, not the incoming maximum.
      → verify: harness prints the child's intrinsic width; if it prints the maximum
      instead, stop and revise the Architecture Decision above before writing any
      widget code.

- [x] In the same harness, render the current settings panel at text scales 1.0, 1.3,
      1.5 and 2.0 and record, per scale, whether any overflow exception is thrown and
      the natural width of the four-segment Colour control against available width.
      → verify: numbers recorded in this file, establishing which scales are actually
      broken today rather than assuming.

## Phase 2 — Shared reflowing setting tile

- [x] Create `lib/widgets/setting_tile.dart` with a `SettingTile` widget taking
      `title` (String), `topic` (`SettingHelpTopic?`), `leading`, `subtitle`,
      `trailing`. It renders `ListTile` with `trailing: null` and a
      `Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center)`
      in the `title` slot, holding the label row and the control. The label row must be
      `MainAxisSize.min` — a max-size row would claim the full width and force a reflow
      at every scale. Read `settings_panel.dart:300-317` for the exact current shape.
      Theme colours only.
      → verify: `flutter analyze lib/widgets/setting_tile.dart` reports no issues.

- [x] Add a horizontal `SingleChildScrollView` inside `CompactSegmented`, around the
      existing `DecoratedBox`, so an oversized control clamps and scrolls instead of
      overflowing. Change nothing else in that file.
      → verify: harness at scale 2.0 shows no overflow exception for the Colour row.

- [x] Replace the shared `_buildSettingTile` (`settings_panel.dart:300`) with a
      delegation to `SettingTile`, so all 17 tiles (lines 46, 58, 71, 84, 100, 118,
      130, 143, 155, 167, 179, 191, 204, 216, 228, 246, 258) pick it up. Do not change
      any call site's arguments.
      → verify: harness at scale 1.0 renders the panel with no layout differences from
      the pre-change run; `flutter analyze` clean.

- [x] Delete the duplicate `_buildSettingTile` in `_BubbleTile`
      (`settings_panel.dart:487`) and point its single call site (line 467) at
      `SettingTile`.
      → verify: only the shared delegate in `_SettingsContentState` remains — no
      `Widget _buildSettingTile` declaration inside `_BubbleTileState`; `flutter analyze`
      clean. (The original criterion, `grep -c` returning 0, was wrong: the shared
      delegate and its 17 call sites keep the name in the file by design.)

- [x] Convert `_HotkeyTile` (`settings_panel.dart:517`) and the reorderable dictionary
      row (`dict_settings_widget.dart:81`) to `SettingTile`, preserving `leading`
      (reorder handle), `subtitle`, and the composite `trailing` row in the hotkey case.
      Keep the dictionary row's `key: ValueKey(id)`.
      → verify: `grep -rn "CompactSegmented" lib/ | grep ListTile` returns nothing;
      `flutter analyze` clean.

- [x] Phase verification: `flutter analyze` reports no new issues and `flutter test`
      matches the pre-change baseline.
      → verify: both run; baseline vs post counts recorded in this file.

## Phase 3 — Header title on one line

- [x] Wrap the header title `Text` at `lib/screens/search_screen.dart:529-536` in
      `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` with
      `maxLines: 1, softWrap: false` on the `Text`, keeping it inside the existing
      `Expanded` and leaving the `GestureDetector(onTap: _goHome)` wiring untouched.
      → verify: harness at scale 2.0 shows the title on one line; app run confirms
      tapping the title still returns to the home state.

## Phase 3b — Logo label (found during Phase 4 verification)

- [x] Set `textScaler: TextScaler.noScaling` on the `dpd` label in
      `lib/widgets/dpd_logo.dart`. The mark is a fixed-size circle whose proportions
      derive from `size`; scaling only the letters inside it clipped them to `d`.
      Pre-existing, not caused by this thread. Both call sites pass an explicit size
      (`download_screen.dart:27` size 80, `search_screen.dart:573` size 30), so neither
      relied on the label scaling.
      → verify: on device at largest font, the logo reads `dpd`.

## Phase 4 — Show the user, then decide the polish

- [x] Run the app and capture the settings panel at default scale and at the largest
      scale, plus the header at both.
      → verify: screenshots produced and shown to the user.

- [x] Ask the user to judge two open questions that only a screenshot can settle:
      whether a horizontally scrolling control at the largest font is good enough or
      should become a vertical list of full-width options, and whether the mixed look
      (two-option rows still side by side while four-option rows reflow) reads as
      inconsistent enough to force all rows to reflow together.
      → verify: user gives a verdict on both; record it here and open follow-up tasks
      only for what they ask for.

  **User verdict, 2026-08-21, largest Android font size:** labels all read normally;
  all four colour options fit on one row without needing to scroll, and look fine — so
  no vertical list is needed and the scroll never engaged; no overflow stripes anywhere
  in the panel; header title on one line; dictionary reordering works. The mixed
  side-by-side/stacked appearance drew no objection. One new defect reported: the logo
  showed only `d` — addressed in Phase 3b.

## Phase 5 — On-device verification

- [x] Install on a real Android device and check the settings panel at the largest
      system font size.
      → verify: no overflow stripes; no label wraps per character; the Colour row's
      four segments all reachable; header stays on one line. **Confirmed by user.**

- [x] Drag a dictionary row in the dictionary list at the largest font size.
      → verify: the row changes position and the new order survives an app restart.
      **Confirmed by user.**

- [ ] Re-check at the largest font size that the logo now reads `dpd`, and at the
      default font size that the settings panel is unchanged from before.
      → verify: user confirms both.

- [x] Delete the scratchpad harness.
      → verify: `git status --short` shows no stray test files.
