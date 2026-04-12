# Plan

Issue reference: GitHub issue #12 - "Add change-log to header info button"

## Phase 1 - Generate a bundled changelog from local git history
- [x] Inspect the existing `justfile` and current build/update entry points to find the smallest set of recipes that should always regenerate the changelog asset.
  - [x] Identify every Just recipe the user relies on to build or update the app.
  - [x] Add changelog generation to those recipes rather than introducing a parallel manual step.
- [x] Add a small changelog generator script driven by local git history.
  - [x] Create a script in a repo-appropriate tooling location that reads git tags and commit messages from the local repository.
  - [x] Group commits into:
    - [x] `unreleased` for commits after the newest release tag
    - [x] tagged release sections for older commits between tags
  - [x] Order sections most recent first.
  - [x] Exclude commits whose subject starts with `chore:`.
  - [x] Keep commit subjects as the displayed changelog items.
  - [x] Write a simple asset file such as `assets/help/changelog.json`.
- [x] Make the generated asset format simple for the Flutter app to read.
  - [x] Store each section with a title/tag and a flat list of commit-message items.
  - [x] Ensure the generator produces stable output when there are no unreleased commits or few tags.
- [x] Automatic verification for Phase 1.
  - [x] Run the generator locally and inspect the produced asset.
  - [x] Verify the asset contains `unreleased` first when applicable and omits `chore:` commits.

## Phase 2 - Show the bundled changelog in the existing info UI
- [x] Extend `lib/widgets/info_popup.dart` to include changelog as a first-class info content type.
  - [x] Add `InfoContent.changelog`.
  - [x] Add a "Change Log" menu item in the existing popup.
- [x] Load and render the generated changelog asset through the existing info-content path.
  - [x] Add an `InfoContentView` branch that reads the bundled changelog asset.
  - [x] Render section headings and their commit-message items in a simple readable layout.
  - [x] Reuse existing theming patterns from the current info UI.
  - [x] Show a stable empty/error state if the asset is missing or empty.
- [x] Keep the behavior path unchanged in `lib/screens/search_screen.dart`.
  - [x] Confirm the new selection uses the existing `_activeInfo` flow and does not introduce a new route.
- [x] Automatic verification for Phase 2.
  - [x] Run focused analysis on the touched Flutter files and confirm the new info-content branch is clean.

## Phase 3 - Add focused verification and finish thread tracking
- [x] Add focused non-UI verification for the changelog generation logic.
  - [x] Cover grouping into `unreleased` and tagged sections.
  - [x] Cover filtering out `chore:` commits.
  - [x] Cover simple/empty-history edge cases as appropriate for the chosen implementation.
- [x] Run final relevant verification for the thread.
  - [x] Re-run the generator.
  - [x] Re-run the focused tests.
  - [x] Re-run focused analysis on changed Dart files.
- [x] Update `plan.md` so each completed item is marked `[x]`, and record any residual limitation explicitly if needed.
- [x] Automatic verification for Phase 3.
  - [x] Confirm the generated asset, app UI, and plan state all match the spec before manual user testing.
