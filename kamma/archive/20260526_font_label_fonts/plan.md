# Plan: Sans/Serif labels in their own fonts

## Architecture Decisions
- Use `GoogleFonts.inter()` / `GoogleFonts.notoSerif()` inline at the call site in `lib/widgets/settings_panel.dart` rather than introducing a helper — the change is two lines.
- Inherit `fontSize` and `color` from the current `DefaultTextStyle` by passing only `fontFamily` overrides so the segmented control's selection styling continues to apply.

## Phase 1 — Apply per-label fonts

- [ ] Update the Font setting's segments in `lib/widgets/settings_panel.dart:86-94` so the "Sans" Text uses `GoogleFonts.inter()` and the "Serif" Text uses `GoogleFonts.notoSerif()`.
  → verify: `flutter analyze lib/widgets/settings_panel.dart` is clean.
- [ ] Manual visual check on running app: open Settings, toggle Font between Sans/Serif, confirm each label always shows in its own face regardless of which is selected.
  → verify: user confirms in Stop 2.
