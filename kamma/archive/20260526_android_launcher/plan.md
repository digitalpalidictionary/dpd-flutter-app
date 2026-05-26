# Plan

## Architecture decisions
- Rename only the release `app_name`; keep `"DPD Debug"` for the debug
  build.
- Fix the squircle halo at the source (`adaptive_icon_background` colour)
  and regenerate via `flutter_launcher_icons` so all densities and
  `colors.xml` stay in sync.
- Use `#00B2FF` (sampled from logo PNG) for the background.

## Phase 1 — Rename launcher label
- [x] Edit `android/app/build.gradle.kts:57`: `"DPD"` → `"Digital Pāḷi Dictionary"`
  → verify: grep shows new release string; debug still says `"DPD Debug"`.

## Phase 2 — Fix squircle white halo
- [x] Edit `pubspec.yaml` `adaptive_icon_background` → `"#00B2FF"`
  → verify: grep shows `#00B2FF`.
- [x] Run `dart run flutter_launcher_icons`
  → verify: `colors.xml` has `ic_launcher_background` = `#00B2FF`; icons regenerated.

## Phase 3 — Manual Android verification (user)
- [ ] Rebuild & install on Android. Long-press icon → label reads
      "Digital Pāḷi Dictionary". Switch launcher icon shape → no white halo.
