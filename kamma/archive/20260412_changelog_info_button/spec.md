# Spec

Issue reference: GitHub issue #12 - "Add change-log to header info button"

## Overview
Add an in-app change log accessible from the header-bar info (`i`) button. The change log will be generated from local git history at build/update time, bundled into the app as a static asset, and shown in most-recent-first order.

## What it should do
- Add a new "Change Log" item to the existing header info popup.
- When selected, replace the main search-results area with a change-log view using the existing info-content flow.
- Generate a simple bundled changelog file from local git tags and commits during normal Just-based app build/update workflows.
- Build the changelog from local git history in this order:
  - an `unreleased` section for commits after the most recent release tag
  - then tagged releases in descending version/date order
- For each section, include associated commit messages.
- Filter out `chore:` commits from the generated changelog.
- Show the most recent section first.

## Relevant repo context
- Issue #12 is open and has no comments.
- The info button/menu lives in `lib/screens/search_screen.dart` and `lib/widgets/info_popup.dart`.
- The main content already switches between normal search content and info content via `_activeInfo` and `InfoContentView`.
- The repo uses a `justfile` for build/update workflows, and the user wants changelog generation included there.
- The app already bundles help assets from `assets/help/`.
- Project instructions prefer simple changes, reuse of existing UI patterns, and no UI tests.
- Runtime access to `.git` is not appropriate for a shipped app, so git history must be converted into a build-time asset.

## Constraints
- Keep the implementation simple.
- Use local git history as the source of truth.
- Include an `unreleased` section for commits after the latest tag.
- Exclude `chore:` commits from the generated output.
- Avoid adding runtime network fetching or release API logic for this feature.
- Keep the UI change within the existing info popup / info content behavior path.
- Do not alter unrelated search, update, or navigation behavior.

## How we'll know it's done
- Running the existing Just build/update flows regenerates a changelog asset from local git history.
- The generated changelog contains `unreleased` first, then tagged releases, newest first.
- `chore:` commits are omitted.
- The header info popup contains a "Change Log" item.
- Selecting it shows the bundled changelog content in the app.
- The change-log view handles empty/missing asset data without crashing.
- Automated verification covers the changelog generation/parsing logic.

## What's not included
- Runtime git access inside the installed app.
- GitHub API calls for changelog data.
- Editing release tags or changing release automation.
- A new route or separate screen just for changelog viewing.
