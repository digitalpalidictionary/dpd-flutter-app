# Spec: Configurable DPD Result Sources In Settings

## Overview

Replace the current hardcoded search-result rendering pipeline with a fully configurable ordering and visibility system that covers all result sources - DPD and non-DPD alike.

Today, DPD result sources always appear and always appear in a fixed order. The existing `DictVisibility` system only controls external dictionaries. This track unifies both into a single ordering and visibility model so that every result source on screen is configurable through the same settings interface.

This is a foundational architectural change to how search results are assembled and displayed, not an incremental addition to the current settings. The implementation must replace the hardcoded result pipeline rather than patch around it.

This feature applies to all DPD result sources that currently appear in search results, including `DPD Summary`, `DPD Headwords`, `DPD Roots`, and all DPD secondary cards. These DPD items should appear above the other dictionaries by default in settings, but remain part of one unified ordering and visibility system rather than a separate settings model.

## Functional Requirements

1. The settings screen must include all DPD result sources in the existing dictionary visibility and reorder UI.
2. The DPD result sources must use the same interaction style and functionality already used for other dictionaries:
   - reorder by drag handle
   - toggle on and off
   - persist order and visibility across app restarts
3. The DPD items must appear above the non-DPD dictionaries by default in settings.
4. The ordering model must remain unified:
   - there is one continuous dictionary ordering experience
   - DPD items are not managed by a separate independent settings section
5. The following DPD result sources must be included:
   - `DPD Summary`
   - `DPD Headwords`
   - `DPD Roots`
   - `DPD Abbreviations`
   - `DPD Deconstructor`
   - `DPD Grammar`
   - `DPD Help`
   - `DPD EPD`
   - `DPD Variants`
   - `DPD Spelling`
   - `DPD See`
6. `DPD Summary` must be included in the same configurable system and must be reorderable and toggleable.
7. `DPD Headwords` must be included in the same configurable system and must be reorderable and toggleable.
8. `DPD Roots` must be included in the same configurable system and must be reorderable and toggleable.
9. Search result rendering must respect the saved visibility and ordering of all result sources instead of using a fixed hardcoded ordering.
10. The user-defined order must apply independently to both result tiers: exact results above the "More Results" divider and partial/fuzzy results below it. Each tier renders its applicable sources in the same user-defined order.
11. Reordering `DPD Headwords` must move both exact and partial headword matches together as one configurable source.
12. `DPD Summary` must only include entries for DPD result sources that are currently enabled.
13. Existing users must preserve their current effective dictionary order and visibility behavior when upgrading.
14. For migration, newly configurable DPD items must be prepended ahead of existing non-DPD dictionaries in the same sequence they currently appear today, so existing users do not experience an unexpected reset.
15. User-facing labels for these items in settings should use the `DPD ...` naming style for clarity and consistency.

## Non-Functional Requirements

1. Reuse the existing settings UI pattern and persistence model wherever possible.
2. Keep the implementation minimal and avoid creating a parallel DPD-only ordering system.
3. DPD source metadata must be defined in code and merged with DB-backed dictionary metadata rather than being represented as database rows.
4. Maintain current visual styling and interaction behavior for reorder handles, on/off controls, spacing, and section presentation.
5. Testing should focus on the main logic only:
   - visibility state
   - ordering state
   - migration/default insertion behavior
   - search-result presentation order filtering
6. This track should avoid unnecessary test expansion beyond the main logic paths needed to protect the feature.
7. Implementation should continue through obstacles by using alternative technical approaches where possible rather than stopping at the first failed attempt.

## Acceptance Criteria

1. A user can open settings and see all DPD result sources, including `DPD Summary`, listed alongside the existing dictionary controls.
2. A user can drag any DPD result source to a new position and the new order is reflected in search results.
3. A user can turn any DPD result source off and it no longer appears in search results.
4. A user can turn any DPD result source back on and it reappears in its saved position.
5. `DPD Summary` behaves like the other configurable DPD items and is not fixed in code.
6. `DPD Headwords` behaves like the other configurable DPD items and is not fixed in code.
7. `DPD Roots` behaves like the other configurable DPD items and is not fixed in code.
8. Moving `DPD Headwords` changes the position of both exact and partial headword results together.
9. `DPD Summary` shows entries only for enabled DPD result sources.
10. The DPD items appear above the other dictionaries by default for users without saved ordering data.
11. Existing users keep their current effective behavior after migration, with DPD items prepended in the current DPD display order rather than appended at the end.
12. The settings UI for DPD items matches the existing dictionary reorder/toggle UI style.
13. The final implementation can be manually verified at the end of the track from the settings screen and the search results screen.

## Out of Scope

1. Redesigning the settings screen beyond the minimal changes needed to include DPD result sources.
2. Changing the visual design of search result cards themselves.
3. Renaming underlying internal model types unless needed to support the feature cleanly.
4. Adding new DPD data sources that do not already exist in the current app.
5. Introducing a separate standalone DPD settings subsystem.
