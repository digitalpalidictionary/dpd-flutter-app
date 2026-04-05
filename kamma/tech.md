# Tech Notes

## Tools & Platforms
This project is a Flutter and Dart app that uses SQLite through Drift and Riverpod for state management. Android is the first priority, and the project is intended to support all major operating systems over time, including mobile, desktop, and web targets already present in the codebase.

## Who This Is For
This app is for monastics, scholars, students, and meditators interested in ancient Buddhist texts.

## Constraints
The main priority is fast startup, fast search, and reliable self-updates for both the app and the database. New work should support those goals rather than slow them down.

## Resources
The project already has an existing Flutter codebase, platform scaffolding, tests, release automation, and a sibling `dpd-db` repository used for database work.

## What The Output Looks Like
The output is a fast dictionary app, starting with Android first, that gives users access to the latest DPD database and related Pali and Sanskrit dictionaries, with broader operating system support over time.
