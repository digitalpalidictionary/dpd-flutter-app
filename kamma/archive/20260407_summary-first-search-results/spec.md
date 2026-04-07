# Spec

## Overview
Improve the search results summary so it presents the headword definition more clearly before the full DPD result cards, without removing the existing button-driven access to grammar, examples, families, and other detailed data.

## What it should do
- Keep the current single search screen behavior and keep summary taps scrolling to the matching full result below.
- Keep the existing classic and compact modes unchanged in overall structure.
- Update headword entries in the top `Summary` section so they show the same core definition content users see in the full entry summary:
  - `lemma_1`
  - `pos`
  - main meaning text
  - `[construction_summary]` when present
- Let headword summary text wrap onto multiple lines instead of truncating to a single ellipsized line.
- Keep the full result card below as the canonical place for the full DPD buttons and expandable sections.
- Leave non-headword summary entries functionally intact unless a small formatting change is needed to keep the section visually coherent.

## Constraints
- Preserve the nature of DPD as a data-rich, button-driven dictionary UI.
- Do not solve this by hiding or removing the existing detailed buttons in classic mode.
- Do not convert the summary into duplicated mini-cards.
- Reuse existing summary and entry-summary formatting patterns where practical so the summary and full result stay aligned.
- Use theme-based styling only.
- Keep the change minimal and localized to the summary/search-result presentation.
- Do not add UI tests.

## How we'll know it's done
- In classic mode, the first visible `Summary` entries for headwords are meaning-led and readable without opening the full card.
- Long headword summaries wrap cleanly on narrow screens instead of being clipped to one line.
- Tapping a summary entry still scrolls to the correct full result below.
- The full result cards still expose the same buttons and detailed sections as before.
- Compact mode behavior remains unchanged.
- Relevant local verification passes.

## What's not included
- Making classic mode accordion-based.
- Removing or redesigning the existing full entry cards.
- Making the summary the canonical source of full entry state.
- A broad redesign of secondary-result summary entries unless required for consistency.
- New UI tests.
