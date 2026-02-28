# Plan: Examples Tab Webapp Parity

## Phase 1: Button Label Parity

- [x] Task: Implement singular/plural button label logic — UI [12e8274]
  - [x] In `accordion_card.dart`: compute `hasTwoExamples = hasEx1 && hasEx2`; pass
        `label: hasTwoExamples ? 'examples' : 'example'` to `DpdSectionButton`
  - [x] Apply the same label logic in `entry_bottom_sheet.dart`
  - [x] Apply the same label logic in `entry_screen.dart` (`ExpansionTile` title text)
  - [x] Commit: `feat: use singular/plural example button label`

---

## Phase 2: Source/Sutta Display Parity

- [ ] Task: Fix source/sutta colour — UI
  - [ ] In `EntryExampleBlock` (`entry_content.dart`): change sutta text colour from
        `theme.colorScheme.outline` to `DpdColors.primaryText`
  - [ ] Commit: `fix: sutta text colour matches webapp primary-text`

- [ ] Task: Fix source/sutta separator — UI
  - [ ] In `EntryExampleBlock`: change the join separator from `' · '` to `' '`
  - [ ] Commit: `fix: sutta separator is single space matching webapp`

- [ ] Task: Render sutta/source line as HTML — UI
  - [ ] Replace the `Text()` source+sutta rendering in `EntryExampleBlock` with an
        `Html()` widget rendering `'$source $sutta'`
  - [ ] Apply a custom stylesheet in the `Html` widget matching `p.sutta` and
        `a.sutta_link` CSS: italic, `DpdColors.primaryText` colour, bold links, no underline
  - [ ] Commit: `feat: render sutta field as HTML for link support`

---

## Phase 3: Container Spacing Parity

- [ ] Task: Fix container horizontal padding — UI
  - [ ] In `accordion_card.dart`: change examples `Padding(horizontal: 16)` to
        `Padding(horizontal: 7)`
  - [ ] Apply the same change in `entry_bottom_sheet.dart`
  - [ ] Apply the same change in `entry_screen.dart`
  - [ ] Commit: `fix: examples container horizontal padding 7px matches webapp`

- [ ] Task: Remove inter-example spacer — UI
  - [ ] In `accordion_card.dart`: remove `SizedBox(height: 16)` between example blocks
  - [ ] Apply the same removal in `entry_bottom_sheet.dart`
  - [ ] Apply the same removal in `entry_screen.dart`
  - [ ] Commit: `fix: remove inter-example gap matching webapp paragraph flow`

---

## Phase 4: Feedback Footer

- [ ] Task: Add `EntryExampleFooter` widget — UI
  - [ ] In `entry_content.dart`: create `EntryExampleFooter` accepting `headwordId`
        (int) and `lemma1` (String)
  - [ ] Widget layout:
    - Container with `border-top: 1px solid primary`, `margin-top: 5px`,
      `padding: 5px 0px`
    - `RichText` at 80 % of body font size (≈ 11.2 px)
    - Plain text: `"Can you think of a better example? "`
    - Tappable `TextSpan`: `"Add it here."` — `DpdColors.primaryText`, bold, no underline
  - [ ] On tap: build URL with `headwordId`, URL-encoded `lemma1`, and today's date;
        launch via `launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)`
  - [ ] Commit: `feat: add EntryExampleFooter widget`

- [ ] Task: Integrate footer in all display contexts — UI
  - [ ] In `accordion_card.dart`: add `EntryExampleFooter(headwordId: h.id, lemma1: h.lemma1)`
        as the last child inside the examples `DpdSectionContainer` column
  - [ ] Apply the same addition in `entry_bottom_sheet.dart`
  - [ ] Apply the same addition in `entry_screen.dart`
  - [ ] Commit: `feat: integrate examples feedback footer in all entry contexts`

---

## Phase 5: Final Verification

- [ ] Task: Conductor - User Manual Verification 'Examples Tab Webapp Parity' (Protocol in workflow.md)
