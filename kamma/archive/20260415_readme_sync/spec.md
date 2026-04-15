# Spec

Issue reference: none

## Overview
Bring `README.md` back in sync with the current project so it accurately explains what the app is, how end users install the beta, how developers run it locally, and how the repo is actually organized today.

## What it should do
- Remove stale Conductor references and replace them with Kamma.
- Link to the Kamma GitHub repository.
- Keep the README focused on the app itself rather than broad implementation detail.
- Add a concise user-install section that:
  - makes it clear the app is in beta
  - links to the DPD install docs
  - links to GitHub releases
- Add a concise developer section that explains the required local tooling and sibling `dpd-db` dependency.
- Add one section listing the relevant direct Flutter/Dart commands.
- Add one separate section listing the relevant `just` recipes used in this repo.
- Sync any setup details with the current codebase and current `justfile`.

## Relevant repo context
- The repo already uses Kamma under `kamma/`.
- The existing README still refers to Conductor and an outdated setup flow.
- Local workflows are centered on `justfile` recipes.
- The app is Android-first for end users, with other Flutter targets present for development.
- Beta installation guidance already exists in `BETA_TESTER.md`.

## Constraints
- Keep the README short and focused.
- Do not add speculative setup steps that are not backed by the current repo.
- Prefer user-facing clarity over implementation detail.

## How we'll know it's done
- `README.md` no longer mentions Conductor.
- `README.md` links to the Kamma repo.
- The install section clearly points users to the beta Android docs and releases.
- Developer setup matches the current repo and `justfile`.
- Flutter/Dart commands and `just` recipes are clearly separated into their own sections.

## What's not included
- Rewriting `BETA_TESTER.md`
- Adding platform-specific install docs beyond the current Android beta links
- Expanding the README into a full architecture document
