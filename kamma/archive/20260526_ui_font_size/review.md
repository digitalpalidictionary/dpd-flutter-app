## Thread
- **ID:** 20260526_ui_font_size
- **Objective:** Separate UI chrome font size from results font size so the header/settings never overflow regardless of the slider value.

## Files Changed
- `lib/widgets/content_text_scale.dart` — new widget: wraps child with MediaQuery textScaler driven by settings.fontSize
- `lib/app.dart` — removed global TextScaler builder (9 lines deleted)
- `lib/screens/search_screen.dart` — wrapped _buildBody output in ContentTextScale
- `lib/screens/entry_screen.dart` — wrapped TapSearchWrapper body in ContentTextScale; FeedbackFooter stays outside
- `lib/screens/root_screen.dart` — same treatment as entry_screen
- `lib/widgets/settings_panel.dart` — renamed "Font size" → "Results font size" in tile + help dialog

## Findings
No findings. One pre-existing warning in search_screen.dart (`isDark` unused_local_variable, line 347) not introduced by this change.

## Fixes Applied
None.

## Test Evidence
- `flutter analyze` (changed files only) → 1 warning, pre-existing, not in our files
- Manual Android test at slider 12/16/20/24 → confirmed by user

## Verdict
PASSED
- Review date: 2026-05-26
- Reviewer: kamma (inline)
