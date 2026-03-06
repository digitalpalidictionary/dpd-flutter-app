# DPD Flutter TODO


## Data
- Optimize mobile.db (remove unused HTML columns)
- add IPA column to db
- Add thanks/bibliography TSV data as DB columns (replace asset bundle approach)
- Add wordlist to database so can ... Gray out unattested forms

## Stage 2: Mobile DB Distribution
- Build GitHub Actions workflow in dpd-db to produce and upload `dpd-mobile.db` as a release asset
- In-app DB update/download mechanism: check GitHub Releases for new version, download if available
- Version checking: compare local DB version (db_info table) against latest GitHub Release tag

## Postponed
- Display IPA transcription in grammar table
- Implement audio playback service and UI buttons
- Add Velthuis typing help guide (track added, implementation in progress)
- Gray out unattested forms in inflection tables

## Review
- Accessibility audit and keyboard refinements
- Review use of different text display widgets across different button sections, and sync
- Review different design patterns used in different button sections
- Remove all html widgets
