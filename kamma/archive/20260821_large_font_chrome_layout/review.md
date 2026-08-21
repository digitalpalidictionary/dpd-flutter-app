## Thread
- **ID:** 20260821_large_font_chrome_layout
- **Objective:** Make app chrome survive large system font sizes; add no new setting, since Android's font-size slider already drives chrome.

## Files Changed
- `lib/widgets/setting_tile.dart` — new shared settings row; `Wrap` in `ListTile`'s title slot so the row reflows by measurement instead of squeezing the label
- `lib/widgets/compact_segmented.dart` — horizontal scroll view so an oversized control clamps instead of overflowing; doc note on the bounded-width requirement
- `lib/widgets/settings_panel.dart` — 17 tiles routed through `SettingTile` via the existing delegate; duplicate `_buildSettingTile` in `_BubbleTile` deleted; `_HotkeyTile` converted
- `lib/widgets/dict_settings_widget.dart` — reorderable dictionary row converted to `SettingTile`
- `lib/screens/search_screen.dart` — header title `FittedBox(scaleDown)` + `HitTestBehavior.opaque`
- `lib/widgets/dpd_logo.dart` — `TextScaler.noScaling` on the `dpd` label (pre-existing defect found during verification)

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | major | `lib/screens/search_screen.dart:577` | `FittedBox` under a `deferToChild` `GestureDetector` hit-tests only the painted glyph box, so the strip beside the title went dead at every scale — worst at 1.0, where the title is far narrower than the `Expanded` | Regression introduced by this thread: `_goHome` stopped working across most of the header | Fixed — `behavior: HitTestBehavior.opaque` |
| 2 | major | `lib/widgets/dict_settings_widget.dart:80`, `lib/widgets/settings_panel.dart:85`, `_HotkeyTile` | Moving the control from `trailing` into `title` re-centres it on the label's line rather than the whole tile, so subtitle rows shift ~10dp and trailing text loses `labelSmall`/`onSurfaceVariant` | Contradicted the spec's "pixel-identical at default scale" promise | Colour restored explicitly; the ~10dp shift accepted as an improvement on `Results font size`, and spec rewritten to state it. Residual: the dictionary row's reorder handle stays tile-centred and no longer lines up with Off/On — needs an eye, not a guess |
| 3 | minor | `lib/widgets/compact_segmented.dart` | Now asserts on unbounded width where it used to merely overflow | Latent trap on a widget used at 18 call sites | Fixed — documented on the class |
| 4 | minor | `spec.md`, `plan.md` | Stale claims: a `CompactSegmented` "two-row state" that does not exist; wording implying the widget was untouched; a `grep -c … returns 0` criterion that is wrong by design | Docs contradicted the code | Fixed — all three rewritten |
| 5 | nit | `lib/widgets/settings_panel.dart:482` | Stray blank line left by the deleted duplicate | Tidiness | Fixed |
| 6 | nit | `lib/widgets/compact_segmented.dart:62` | Segments are bare `GestureDetector`s with no `Semantics(button/selected)` and a sub-48dp tap height | Accessibility gap — but pre-existing and untouched | Not fixed; out of scope, logged as a follow-up |
| 7 | nit | `lib/widgets/setting_tile.dart:52` | Minimum label↔control gap drops 16dp → 8dp; reflowed control lands left-aligned | Only visible in the just-barely-fits case; user approved the reflowed look on device | Accepted |

## Fixes Applied
- Header tap target restored to the full header strip.
- `Results font size` number's colour pinned to `onSurfaceVariant`.
- `CompactSegmented` documented as requiring bounded width.
- Stray blank line removed.
- `spec.md` and `plan.md` corrected on all four false claims.

## Test Evidence
- `flutter analyze` (scope: whole project) → 51 issues, all `info`, all pre-existing in `lib/utils/pali_transliterator/**` and `lib/utils/search_timing.dart`. Identical to the pre-change baseline; no new issues.
- `flutter test` (scope: whole project, 381 tests) → all pass. **Neutral evidence only** — no test touches `CompactSegmented`, `SettingTile`, `SettingsContent`, `DpdLogo`, or the header, and `AGENTS.md` forbids adding UI tests.
- Throwaway probe, since deleted (scope: layout algorithm only, not appearance) → `SingleChildScrollView` measured 80 under a 360 maximum, confirming it takes its child's width; old tile shape threw `RenderBox was not laid out` with the label's paragraph at `NEEDS-LAYOUT`; new tile produced zero layout errors at scales 1.0 / 1.15 / 1.3 / 1.5 / 2.0.
- CodeRabbit (scope: the five modified files; **`setting_tile.dart` not included** — untracked files are absent from an uncommitted diff) → zero findings. A re-run that would have covered the new file hit the free-tier rate limit and was abandoned at the user's instruction. The new widget therefore has agent review only.
- On-device, largest Android font size (scope: settings panel + header, one device) → user confirmed labels read normally, all four colour options fit one row without scrolling, no overflow stripes, header on one line, dictionary reordering works, logo reads `dpd`.

## Not Verified
- **Default-scale appearance after the review fixes.** The user's device pass predates fixes 1, 2, 3 and 5. The header tap fix in particular is behavioural and unexercised.
- The dictionary row's reorder-handle alignment against Off/On on a subtitle row — predicted by arithmetic over `list_tile.dart`, never seen.
- Exact scale at which any given row starts to reflow. No fonts are bundled (`google_fonts` fetches at runtime), so widget-test glyph widths are meaningless and this is unknowable outside a running app.
- TalkBack behaviour with the new per-row `Scrollable`.
- Anything below the largest font notch — only default and largest were exercised on device.
- `lib/widgets/setting_tile.dart` by any external tool.

## Verdict
PASSED
- Review date: 2026-08-21
- Reviewer: independent zero-context agent (Sections 4.0–6.0) + CodeRabbit on the modified files; findings triaged and fixed in the implementing session
