# Product Guidelines — DPD Flutter App

## Tone & Prose Style

- **Minimal and functional.** Short labels, no unnecessary text. Let the dictionary content speak for itself.
- UI copy should be clear, direct, and unambiguous.
- Avoid marketing language, exclamation marks, or conversational filler.
- Error messages should state what happened and what the user can do, nothing more.

## Visual Identity

### Match the DPD Webapp

The app's visual design must match the DPD webapp dictionary pane as closely as possible. The app should feel like a native mobile version of the webapp.

### Color System

| Token | Value | Usage |
|-------|-------|-------|
| Primary | `hsl(198, 100%, 50%)` / `#00BFFF` | Borders, buttons, accents, search bar |
| Primary Alt | `hsl(205, 100%, 40%)` | Hover/pressed states |
| Primary Light | `hsl(198, 100%, 95%)` | Light mode backgrounds |
| Primary Dark | `hsl(198, 100%, 5%)` | Dark mode backgrounds |
| Gray | `hsl(0, 0%, 50%)` | Muted text, dividers |
| Gray Transparent | `hsla(0, 0%, 50%, 0.15)` | Table header backgrounds |

### Typography

| Property | Value |
|----------|-------|
| Default font | Inter (sans-serif) |
| Alternate font | Noto Serif (togglable in settings) |
| Base size | User-adjustable (default 16px equivalent) |
| Line height | 150% |

### Component Styling

- **Borders:** 2px solid primary color, 7px border-radius
- **Buttons:** Primary color background, rounded 7px, shadow elevation on hover/press
- **Expandable sections:** Hidden by default, toggled via button tap
- **Tables:** Left-aligned, minimal borders, gray-transparent header backgrounds
- **Summary box:** Cyan left border accent, always visible

### Dark Mode

- Full dark mode support matching webapp behavior
- Inverted background/foreground; primary accent color remains unchanged
- User toggle: light / dark / system

## UX Guidelines

### Adjustable Font Size
- Users can increase/decrease text size via settings
- Font size preference persists across sessions
- Applies to all dictionary content and UI elements

### One-Button Toggle Mode
- When enabled, only one expandable section can be open at a time
- Tapping a new section closes the previously open one
- Matches the webapp's existing toggle behavior
- User-configurable in settings

### Offline-First UX
- The app must never show network error states during normal dictionary use
- All dictionary functionality works with zero internet connectivity
- Network is only required for initial database download and updates
- Update checks fail silently; manual "Check for updates" button available in settings

### Database Schema Compatibility
- The app and mobile DB share a schema version contract via `db_schema_version` in the `db_info` table
- `AppDatabase.requiredDbSchemaVersion` (Flutter) must match `DB_SCHEMA_VERSION` (Python exporter) — bump both when Drift table definitions change
- On startup, if the on-device DB's `db_schema_version` < the app's required version, the app shows a blocking download screen (same as first install) before allowing any queries
- If the DB is newer than the app (extra columns), extra columns are silently ignored — no forced download
- `onUpgrade` migration is a no-op (DB is always replaced wholesale); `beforeOpen` resets `PRAGMA user_version` to prevent Drift downgrade errors
- Fallback: DBs without `db_schema_version` are treated as version 2 (the version when this mechanism was introduced)

### Additional Customization (Beyond Webapp)
- Grammar section default state: open or closed
- Examples section default state: open or closed
- Per-section default state preferences (future)
- Additional display preferences as user needs emerge

## Content Guidelines

- All Pāḷi text must render diacritics correctly (ā, ī, ū, ṃ, ṁ, ṅ, ñ, ṭ, ḍ, ṇ, ḷ)
- Pāḷi headwords displayed in Roman script by default
- HTML content from the database (inflection tables, frequency charts, examples) rendered faithfully
- Empty fields and sections are hidden, never shown as blank
