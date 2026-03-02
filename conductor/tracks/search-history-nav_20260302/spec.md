# Search History & Navigation

## Overview

Implement a search history feature with forward/backward navigation buttons for the DPD Flutter app, mirroring the webapp's mobile/small-screen behavior. The history panel displays at the bottom of the search screen with horizontally scrollable search terms. Navigation buttons (back/forward) appear just below the search bar.

## Webapp Reference

### HTML Structure (home.html lines 113-121)
```html
<div class="history-pane" id="history-pane">
    <div class="pane-header">
        <h3 class="dpd">History<button class="clear-history-button" id="clear-history-button" title="Clear history">x</button></h3>
        <button class="collapse-toggle" id="history-collapse-toggle" aria-label="Toggle history">
            <span class="collapse-icon">▼</span>
        </button>
    </div>
    <div class="history-list-pane" id="history-list-pane"></div>
</div>
```

### CSS - History Pane Base (home.css)
```css
.history-pane {
  border-radius: 7px;
  border: 2px solid var(--gray-transparent);
  display: flex;
  flex-direction: column;
  flex: 1;
  list-style-type: none;
  overflow-x: auto;
  overflow-y: auto;
  padding: 5px 20px;
  position: relative;
}

.history-pane h3 {
  text-align: left;
  margin: 0;
  padding: 5px 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.clear-history-button {
  background-color: var(--primary);
  border-radius: 50%;
  border: none;
  box-shadow: var(--shadow-default);
  color: var(--dark);
  cursor: pointer;
  display: inline-flex;
  font-size: 0.8em;
  padding: 5px 10px;
  transition: 1s;
  width: auto;
  align-items: center;
  justify-content: center;
  min-width: 24px;
  height: 24px;
}

.clear-history-button:hover {
  box-shadow: var(--shadow-hover);
  background-color: red;
}
```

### CSS - Mobile/Small Screen Layout (home.css lines 951-1048)
```css
@media (max-width: 576px) {
  .history-pane {
    order: 2;
    padding: 5px;
    width: auto;
    margin: 5px;
    box-sizing: border-box;
  }

  .history-pane h3 {
    text-align: center;
    padding-bottom: 0px;
    margin-bottom: 0%;
  }

  .history-list-pane {
    white-space: nowrap;
    overflow-x: auto;
  }

  .history-list-pane ul {
    padding-left: 0;
    list-style-type: none;
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 0.3em;
  }

  li:not(:last-child)::after {
    content: ", ";
  }

  .collapse-toggle {
    display: flex;
    padding: 8px;
    min-width: 28px;
    height: 28px;
  }

  .history-pane.collapsed .history-list-pane {
    display: none;
  }
}
```

### JS - State Management (app.js)
```javascript
// State structure
const appState = {
  history: [],           // Array of state snapshots
  historyIndex: -1,      // Current position in history stack
  historyPanelEntries: [], // Array of search terms for display (max 250)
};

// Key functions
addToHistory()           // Push new search to history
handlePopState(event)    // Handle back/forward navigation
clearHistory()           // Clear all history
searchHistoryItem(entry) // Re-search from history panel
updateHistoryPanel()     // Render history list

// LocalStorage keys
localStorage.setItem("dpdFullHistory", JSON.stringify(appState.history));
localStorage.setItem("dpdHistoryPanel", JSON.stringify(appState.historyPanelEntries));
```

## Functional Requirements

### FR1: History State Management
- Maintain a history stack of search states
- Track current position index within the history
- Each history entry stores: search term, and optionally the headword ID for ID-based searches
- History persists across app restarts via SharedPreferences

### FR2: History Panel Display
- Display at the bottom of the search screen
- Header row: "History" title with clear button (x) and collapse toggle (▼)
- History items displayed horizontally in a scrollable row
- Items separated by commas (text-based, not chips)
- Tapping an item re-searches that term
- Items moved to front when re-searched

### FR3: Navigation Buttons
- Back (←) and Forward (→) buttons positioned just below the search bar
- Back button enabled when `historyIndex > 0`
- Forward button enabled when `historyIndex < history.length - 1`
- Tapping back navigates to previous search state
- Tapping forward navigates to next search state
- Visual disabled state for inactive buttons

### FR4: Clear History
- "x" button next to "History" header
- Tapping clears all history entries
- Confirmation not required (matches webapp behavior)
- Button turns red on hover/long-press (matches webapp CSS)

### FR5: Collapse/Expand
- Collapse toggle (▼) to hide/show history list
- Collapsed state persists in SharedPreferences
- Icon rotates -90° when collapsed

### FR6: History Limits
- Maximum 50 history entries
- When limit reached, oldest entries removed (FIFO)
- Duplicate search terms moved to front instead of added

## Non-Functional Requirements

### NFR1: Performance
- History lookup and navigation should be instant (< 16ms)
- SharedPreferences reads should not block UI

### NFR2: Storage
- Use SharedPreferences for persistence (simple key-value)
- Store as JSON string for history array

### NFR3: Styling
- Match webapp CSS values:
  - Border: 2px solid gray-transparent
  - Border-radius: 7px
  - Padding: 5px
  - Primary color: hsl(198, 100%, 50%) / #00BFFF
  - Clear button: circular, 24px diameter

## Acceptance Criteria

1. **AC1:** After searching "dhamma", then "kamma", history panel shows "kamma, dhamma"
2. **AC2:** Tapping "dhamma" in history re-searches it and moves it to the front
3. **AC3:** Back button navigates to previous search and updates search field
4. **AC4:** Forward button navigates to next search and updates search field
5. **AC5:** Clear button removes all history entries
6. **AC6:** Collapsing history persists across app restarts
7. **AC7:** History persists across app restarts (up to 50 entries)
8. **AC8:** Navigation buttons are disabled when at history boundaries
9. **AC9:** Double-tap search adds to history
10. **AC10:** History panel styling matches webapp mobile layout

## Out of Scope

- Tab-based history (DPD tab only, no Bold Definitions or Tipitaka tabs)
- Full state snapshots with results HTML (only search terms stored)
- History sync across devices
- History export/import