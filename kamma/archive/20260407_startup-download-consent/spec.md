# Spec

## Overview
Fix issue #1 by stopping the app from automatically downloading the dictionary on first launch. When no local database is present, the app should first show a consent prompt that matches existing popup patterns and theme styling, then start the download only after the user explicitly agrees.

## What it should do
- Detect the first-install state without immediately starting the database download.
- Show a startup permission dialog before any download begins.
- Reuse the app's existing popup pattern and Material 3 styling instead of inventing a new UI pattern.
- Explain that the dictionary database will be downloaded and that the user can wait until they are on Wi-Fi if preferred.
- Start the existing download flow unchanged when the user confirms.
- Keep the blocking startup behavior for cases where the app cannot continue without a usable database.
- If the user chooses not to download yet, keep the app open on a blocked first-run screen with a clear explanation and a `Download now` action.
- Preserve existing progress, extraction, retry, and error handling once the download has started.

## Constraints
- Use existing dialog/popup patterns already present in the codebase.
- Use theme-based colors and current button conventions.
- Keep the change minimal and localized to the startup database update flow.
- Do not add UI tests.
- Prefer non-UI verification around state transitions and startup logic.

## How we'll know it's done
- On a fresh install with no local database, the app does not begin downloading automatically.
- The user sees a consent dialog before any download begins.
- Tapping the confirm action starts the current download flow and shows the existing download progress UI.
- Tapping `Not now` does not start the download and leaves the app on a blocked screen with a `Download now` action.
- Existing update/download behavior for users who already have a local database still works.
- Relevant local verification passes.

## What's not included
- A new settings screen for download permissions.
- Persistent "ask again later" scheduling beyond the current startup session.
- Changes to background update policy for users who already have a database.
- Redesigning the full download screen.
