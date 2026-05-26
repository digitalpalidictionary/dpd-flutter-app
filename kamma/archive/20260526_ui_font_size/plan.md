# Plan: Separate UI font size from results font size

## Architecture Decisions
- **Invert the scaling strategy.** Remove the global TextScaler and apply
  the user's scaler only around content roots. Material-standard pattern.
- **One small wrapper widget** — `ContentTextScale` — reads
  `settingsProvider.fontSize`, computes `scale = fontSize / 16`, and wraps
  its child in `MediaQuery(textScaler: TextScaler.linear(scale))` that
  replaces the inherited scaler.
- **Three wrap sites only**: search-screen `_buildBody` return, EntryScreen
  body, RootScreen body. Keeps blast radius small.
- **Slider label renamed** to "Results font size".

## Phase 1 — Rewire scaling

- [x] Create `lib/widgets/content_text_scale.dart` with a `ContentTextScale`
      ConsumerWidget that wraps `child` in a `MediaQuery` overriding
      `textScaler` to `TextScaler.linear(settings.fontSize / 16)`.
      → verify: `flutter analyze lib/widgets/content_text_scale.dart` clean.

- [x] In `lib/app.dart`, remove the `builder:` that applies the global
      TextScaler (lines ~236-244). Leave the rest of MaterialApp intact.
      → verify: `flutter analyze lib/app.dart` clean.

- [x] In `lib/screens/search_screen.dart`, wrap the return value of
      `_buildBody(...)` in `ContentTextScale(child: ...)`.
      → verify: analyze clean; visually with slider at 24, header single-line.

- [x] In `lib/screens/entry_screen.dart`, wrap the `Scaffold` body inside
      `_EntryView.build` in `ContentTextScale`. Keep `bottomNavigationBar`
      outside the wrap.
      → verify: analyze clean.

- [x] In `lib/screens/root_screen.dart`, mirror the entry_screen treatment.
      → verify: analyze clean.

- [x] In `lib/widgets/settings_panel.dart`, rename `'Font size'` →
      `'Results font size'`. Update `_fontSizeTopic` help body to clarify
      scope.
      → verify: analyze clean.

- [ ] Phase verification:
      → `flutter analyze` clean across all changed files.
      → Manual run on Android: slider at 12, 16, 20, 24 — header single-line,
        settings rows clean, results/entry/root body scales, footers fixed.
