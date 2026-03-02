# Spec: Lookup-Based Secondary Search Results

## Overview

Integrate all lookup-table secondary data types into the Flutter app's search results. When a user searches for a word, the app currently shows DPD headword entries and root entries. The webapp also displays additional result types sourced from the `lookup` table: **deconstructor**, **grammar dictionary**, **abbreviations**, **help**, **EPD (English-Pali Dictionary)**, **variant readings**, **spelling corrections**, and **see (cross-references)**. This track adds all of these as always-visible cards in search results, rendered below headword and root results in webapp order.

## Functional Requirements

### FR-1: Extend Lookup Table Schema

Add missing columns to the Drift `Lookup` table definition:
- `deconstructor` (`text().nullable()`) — JSON `list[str]` of deconstruction strings
- `epd` (`text().nullable()`) — JSON `list[list[str]]` of 3-tuples: `[headword, pos_info, meaning]`

The DB rebuild script must include these columns when exporting. Existing columns already in the Flutter schema that will now be used: `variant`, `see`, `spelling`, `grammar`, `help`, `abbrev`.

### FR-2: Data Models for Each Result Type

Create Dart data classes to hold parsed lookup data. Each model is constructed from the raw JSON string in the lookup row:

| Model | Source Column | JSON Format | Parsed Type |
|---|---|---|---|
| `DeconstructorResult` | `deconstructor` | `list[str]` | `List<String>` — each string is a deconstruction like "ava + loketi" |
| `GrammarDictResult` | `grammar` | `list[list[str, str, str]]` | `List<GrammarDictEntry>` where each entry has `headword`, `pos`, `components` (list of up to 3 strings) |
| `AbbreviationResult` | `abbrev` | `dict{meaning, pāli?, example?, explanation?}` | Single object with `meaning` (required), `pali`, `example`, `explanation` (all optional) |
| `HelpResult` | `help` | `str` (JSON-encoded string) | Single `String` |
| `EpdResult` | `epd` | `list[list[str, str, str]]` | `List<EpdEntry>` where each entry has `headword`, `posInfo`, `meaning` |
| `VariantResult` | `variant` | `dict{corpus: {book: [[context, variant], ...]}}` | Nested map structure for table display |
| `SpellingResult` | `spelling` | `list[str]` | `List<String>` — each string is a correct spelling |
| `SeeResult` | `see` | `list[str]` | `List<String>` — each string is a headword to cross-reference |

### FR-3: DAO Query Extension

Extend `DpdDao` so that when a lookup row is fetched for search, all columns are returned (not just `headwords` and `roots`). The existing search flow fetches a `Lookup` row by key — the new columns will simply be read from that same row.

### FR-4: Search Results Display Order

When displaying search results for a query, the order must be:

1. **DPD Headwords** (existing — from `lookup.headwords`)
2. **DPD Roots** (existing — from `lookup.roots`)
3. **Abbreviations** (from `lookup.abbrev`)
4. **Deconstructor** (from `lookup.deconstructor`)
5. **Grammar Dictionary** (from `lookup.grammar`)
6. **Help** (from `lookup.help`)
7. **EPD** (from `lookup.epd`)
8. **Variant Readings** (from `lookup.variant`)
9. **Spelling Corrections** (from `lookup.spelling`)
10. **See / Cross-references** (from `lookup.see`)

Each type only appears if its column is non-null and non-empty.

### FR-5: Always-Visible Card Widgets — Exact HTML/CSS Reference

Each secondary result type is rendered as an always-visible card (no toggle buttons). The Flutter widgets must reproduce the exact visual output of the following webapp HTML/CSS.

---

#### Shared CSS Foundation (applies to ALL card types)

```css
/* --- Base element styles --- */
h3, h3.dpd {
  font-size: 130%;
  margin-top: 10px;
  margin-bottom: 1px;
}

/* Standard primary-bordered container (used by deconstructor, grammar, EPD, variant, spelling, see) */
div.dpd {
  border: 2px solid var(--primary);         /* hsl(198, 100%, 50%) / #00BFFF */
  border-radius: 7px;
  line-height: 150%;
  margin: 0px 0px;
  overflow: auto;
  padding: 3px 7px;
  text-align: left;
  touch-action: manipulation;
}

/* Green-bordered container (used by abbreviations, help) */
div.tertiary {
  border: 2px solid var(--secondary);       /* hsl(158, 100%, 35%) — green */
  border-radius: 7px;
  line-height: 150%;
  margin: 0px 0px;
  overflow: auto;
  padding: 3px 5px;
  text-align: left;
}

p {
  line-height: 150%;
  margin: 0px 0px;
  vertical-align: middle;
  text-align: left;
}

b { font-weight: 700; }

/* Footer — thin primary-color top border, small text */
p.dpd-footer {
  border-top: 1px solid var(--primary);
  font-size: 80%;
  padding: 5px 0px;
  margin-top: 5px;
}

.dpd-link {
  color: var(--primary-text);               /* hsl(205, 79%, 48%) */
  font-weight: 700;
  text-decoration: none;
}

/* Horizontal rule used in variant table */
hr.dpd {
  background-color: var(--gray-transparent); /* hsla(0, 0%, 50%, 0.25) */
  width: 100%;
  border: none;
  height: 1px;
  margin: 0;
  padding: 0;
  display: block;
}

/* --- CSS Variables --- */
:root {
  --light:            hsl(198, 100%, 95%);
  --dark:             hsl(198, 100%, 5%);
  --primary:          hsl(198, 100%, 50%);
  --primary-alt:      hsl(205, 100%, 40%);
  --primary-text:     hsl(205, 79%, 48%);
  --gray:             hsl(0, 0%, 50%);
  --gray-transparent: hsla(0, 0%, 50%, 0.25);
  --secondary:        hsl(158, 100%, 35%);   /* green for tertiary */
}
```

---

#### FR-5.1: Deconstructor Card

**Webapp HTML:**
```html
<h3 class="dpd" id="deconstructor: {{ d.headword }}">deconstructor: {{d.headword}}</h3>
<div class="dpd">
  <p>
    {% for deconstruction in d.deconstructions: %} {{deconstruction}} {% if not
    loop.last: %}
    <br />
    {% endif %} {% endfor %}
  </p>
  <p class="dpd-footer">
    These word breakups are code-generated. For more information,
    <a class="dpd-link" href="https://digitalpalidictionary.github.io/features/deconstructor/" target="_blank">read the
      docs</a>. Please
    <a class="dpd-link"
      href="https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500={{ d.headword }}&entry.326955045=Deconstructor&entry.1433863141={{d.app_name}}+{{d.date}}"
      target="_blank">suggest any improvements here</a>. Mistakes in
    deconstruction are usually caused by a word missing from the
    dictionary. You can
    <a class="dpd-link"
      href="https://docs.google.com/forms/d/e/1FAIpQLSfResxEUiRCyFITWPkzoQ2HhHEvUS5fyg68Rl28hFH6vhHlaA/viewform?usp=pp_url&entry.1433863141={{d.app_name}}+{{d.date}}"
      target="_blank">add missing words here</a>.
  </p>
</div>
```

**Styling:** Uses `div.dpd` (primary blue border). Content is plain text strings separated by `<br>`. Footer has three `dpd-link` anchors.

**Data format:** `lookup.deconstructor` → JSON `list[str]`, e.g. `["ava + loketi", "ava + loka + eti"]`

---

#### FR-5.2: Grammar Dictionary Card

**Webapp HTML:**
```html
<h3 class="dpd" id="grammar: {{ d.headword }}">grammar: {{d.headword}}</h3>
<div class='dpd'>
    <table class='grammar_dict'>
        <thead>
            <tr>
                <th id='col1'>pos ⇅</th>
                <th id='col2'>⇅</th>
                <th id='col3'>⇅</th>
                <th id='col4'>⇅</th>
                <th id='col5'></th>
                <th id='col6'>word ⇅</th>
            </tr>
        </thead>
        <tbody>
            {% for item in d.grammar: %}
            <tr>
                <td><b>{{item[1]}}</b></td>
                {% for comp in item[2]: %}
                    {% if comp == "" %}
                    <td class='col_empty'></td>
                    {% else %}
                    <td>{{comp}}</td>
                    {% endif %}
                {% endfor %}
                <td>of</td>
                <td>{{item[0]}}</td>
            </tr>
            {% endfor %}
        </tbody>
    </table>
    <p class="dpd-footer">
        For more information, please <a class="dpd-link"
            href='https://digitalpalidictionary.github.io/features/grammardict/'
            target='_blank'>read the docs</a>.
    </p>
</div>
```

**CSS specific to this card:**
```css
table.variants,
table.grammar_dict {
  border-collapse: collapse;
  border: none;
  line-height: 150%;
  margin: 0px;
  max-width: 100%;
  overflow: auto;
  padding: 2px 0px;
  text-align: left;
  vertical-align: top;
  width: auto;
}

.grammar_dict th,
.grammar_dict td {
  padding: 2px 10px 0px 0px;
  text-align: left;
  vertical-align: center;
}

/* Empty grammar component cells are hidden entirely */
.grammar_dict .col_empty {
  display: none;
}
```

**Data format:** `lookup.grammar` → JSON `list[list]`, each item is `[headword, pos, grammar_string]`. The `grammar_string` is split into up to 3 components and padded with empty strings. Each row renders as: **pos** | comp1 | comp2 | comp3 | "of" | word.

**Note on sort arrows (⇅):** The webapp has clickable column sorting via JS. In the Flutter app, render the table headers WITHOUT sort arrows (no interactivity needed). Use header labels: "pos", (no label), (no label), (no label), (no label), "word".

---

#### FR-5.3: Abbreviations Card

**Webapp HTML:**
```html
<h3 class="dpd" id="abbreviation: {{ d.headword }}">{{d.headword}}</h3>
<div class="tertiary">
    <table class="help">
        <tr>
            <th>Abbreviation</th>
            <td><b>{{d.headword|safe}}</b></td>
        </tr>
        <tr>
            <th>Meaning</th>
            <td>{{d.meaning|safe}}</td>
        </tr>
        {% if d.pali: %}
        <tr>
            <th>Pāḷi</th>
            <td>{{d.pali|safe}}</td>
        </tr>
        {% endif %}
        {% if d.example: %}
        <tr>
            <th>Example</th>
            <td>{{d.example|safe}}</td>
        </tr>
        {% endif %}
        {% if d.explanation: %}
        <tr>
            <th>Information</th>
            <td>{{d.explanation|safe}}</td>
        </tr>
        {% endif %}
    </table>
</div>
```

**CSS specific to this card:**
```css
div.tertiary {
  border: 2px solid var(--secondary);       /* hsl(158, 100%, 35%) — GREEN border */
  border-radius: 7px;
  line-height: 150%;
  margin: 0px 0px;
  overflow: auto;
  padding: 3px 5px;
  text-align: left;
}

table.help {
  border: none;
  width: 100%;
}

table.help td, table.help th {
  line-height: 150%;
  padding: 0px 5px 0px 0px;
  text-align: left;
  vertical-align: top;
}

table.help th {
  color: var(--secondary);                  /* GREEN text for labels */
  font-weight: 700;
  width: 10%;
}

table.help td {
  width: 90%;
}
```

**Key visual differences from other cards:**
- Border is GREEN (`--secondary`), not blue (`--primary`)
- Table header labels are GREEN, not blue
- Header text is just `{searchTerm}` — NO prefix like "abbreviation:"
- No `dpd-footer`

**Data format:** `lookup.abbrev` → JSON `dict`, e.g. `{"meaning": "adjective", "pāli": "visesana", "example": "loka", "explanation": "..."}`
- `meaning` is always present
- `pali`, `example`, `explanation` are conditional — only render their rows if non-empty

---

#### FR-5.4: Help Card

**Webapp HTML:**
```html
<h3 class="dpd" id="help: {{ d.headword }}">{{d.headword}}</h3>
<div class="tertiary">
    <table class="help">
        <tr>
            <th>Help</th>
            <td><b>{{d.headword|safe}}</b></td>
        </tr>
        <tr>
            <th>Meaning</th>
            <td>{{d.help|safe}}</td>
        </tr>
    </table>
</div>
```

**CSS:** Identical to Abbreviations — uses `div.tertiary` (green border) and `table.help` (green header labels). See FR-5.3 CSS above.

**Key notes:**
- GREEN border, GREEN labels (same as abbreviations)
- Header text is just `{searchTerm}` — no prefix
- Always exactly 2 rows: "Help" and "Meaning"
- No `dpd-footer`

**Data format:** `lookup.help` → JSON-encoded string (not a list), e.g. `"\"Use the search bar to look up...\""`. Unpacked via `json.loads()` to a plain `String`.

---

#### FR-5.5: EPD (English-Pali Dictionary) Card

**Webapp HTML:**
```html
<h3 class="dpd" id="English: {{ d.headword }}">English: {{d.headword}}</h3>
<div class="dpd">
    {% for item in d.epd %}
    <p>
        <b class="epd">{{ item.0 }}</b>
        {% if item.1 %}
        {{ item.1|safe }}.
        {% endif %}
        {{ item.2|safe }}.
    </p>
    {% endfor %}
</div>
```

**CSS specific to this card:**
```css
.epd {
  color: var(--primary-text);               /* hsl(205, 79%, 48%) — blue text */
}
```

**Styling:** Uses `div.dpd` (primary blue border). Each EPD entry is a `<p>` with:
1. Bold headword in primary-text color (`.epd` class)
2. Optional pos/info text followed by period
3. Meaning text followed by period

**No footer.**

**Data format:** `lookup.epd` → JSON `list[list[str, str, str]]`, each item is `[epd_headword, pos_info_or_empty, meaning]`.

---

#### FR-5.6: Variant Readings Card

**Webapp HTML:**
```html
<h3 class="dpd" id="variants: {{ d.headword|safe }}">variants: {{ d.headword|safe }}</h3>
<div class="dpd">
    <table class="variants">
        <tr>
            <th>source</th>
            <th>filename</th>
            <th>context</th>
            <th>variant</th>
        </tr>

        {% set old_corpus = None %}
        {% for corpus, data2 in d.variants.items() %}

        {% if old_corpus != corpus %}
        <tr>
            <td colspan="4">
                <hr class="dpd">
            </td>
        </tr>
        {% endif %}

        {% for book, data3 in data2.items() %}
        {% for data4 in data3 %}
        <tr>
            <td>{{ corpus }}</td>
            <td>{{ book }}</td>
            <td>{{ data4[0] }}</td>
            <td>{{ data4[1] }}</td>
        </tr>
        {% endfor %}
        {% endfor %}

        {% set old_corpus = corpus %}
        {% endfor %}
    </table>
    <p class="dpd-footer">
        For details on how to use this, please <a class="dpd-link" href='https://digitalpalidictionary.github.io/features/variants/' target='_blank'>read the docs</a>.
    </p>
</div>
```

**CSS specific to this card:**
```css
table.variants,
table.grammar_dict {
  border-collapse: collapse;
  border: none;
  line-height: 150%;
  margin: 0px;
  max-width: 100%;
  overflow: auto;
  padding: 2px 0px;
  text-align: left;
  vertical-align: top;
  width: auto;
}

.variants th,
.variants td {
  padding: 2px 10px 0px 0px;
  text-align: left;
  vertical-align: center;
}

/* First two columns (source, filename) don't wrap */
.variants td:first-child,
.variants td:nth-child(2) {
  white-space: nowrap;
}

/* Corpus separator */
hr.dpd {
  background-color: var(--gray-transparent);
  width: 100%;
  border: none;
  height: 1px;
  margin: 0;
  padding: 0;
  display: block;
}
```

**Data format:** `lookup.variant` → JSON nested dict: `{corpus_name: {book_name: [[context_str, variant_str], ...]}}`. Corpus groups are separated by `<hr>`. Table has 4 columns: source, filename, context, variant.

---

#### FR-5.7: Spelling Corrections Card

**Webapp HTML:**
```html
<h3 class="dpd" id="spelling: {{ d.headword }}">spelling: {{d.headword}}</h3>
<div class='dpd'>
    <p>
        {% for spelling in d.spellings: %}
        incorrect spelling of <b><i>{{spelling}}</i></b>
        {% if not loop.last: %}
        <br>
        {% endif %}
        {% endfor %}
    </p>
</div>
```

**Styling:** Uses `div.dpd` (primary blue border). Content is plain paragraph text. Each entry is "incorrect spelling of **_correctWord_**" in bold italic. Multiple entries separated by `<br>`.

**No footer.**

**Data format:** `lookup.spelling` → JSON `list[str]`, e.g. `["dhamma", "dhammo"]`.

---

#### FR-5.8: See / Cross-References Card

**Webapp HTML:**
```html
<h3 class="dpd" id="see: {{ d.headword }}">see: {{d.headword}}</h3>
<div class='dpd'>
    <p>
        {% for headword in d.see_headwords: %}
        see <b><i>{{headword}}</i></b>
        {% if not loop.last: %}
        <br>
        {% endif %}
        {% endfor %}
    </p>
</div>
```

**Styling:** Uses `div.dpd` (primary blue border). Identical structure to spelling. Each entry is "see **_headword_**" in bold italic. Multiple entries separated by `<br>`.

**No footer.**

**Data format:** `lookup.see` → JSON `list[str]`, e.g. `["kamma", "kamma 2"]`.

---

### FR-6: Provider Integration

Create a provider (or extend existing search providers) that:
1. Parses each non-empty lookup column into its typed data model
2. Exposes the list of secondary results to the search screen
3. Results are computed from the same `Lookup` row already fetched for headword/root search (no additional DB query)

### FR-7: Display Mode Compatibility

Secondary result cards must render correctly in all three display modes:
- **Inline** — cards appear directly in the scrollable results list
- **Accordion** — cards appear below the accordion entries
- **Bottom Sheet** — cards appear in the scrollable content area

## Non-Functional Requirements

- **NFR-1:** No additional database queries beyond the existing lookup fetch. All data comes from the already-fetched `Lookup` row.
- **NFR-2:** Cards must respect the user's theme (light/dark mode) and font size settings.
- **NFR-3:** Empty/null columns must produce no visible output — no empty cards, no blank space.

## Acceptance Criteria

1. Searching for a Pali word that has deconstructor data shows a deconstructor card below headword/root results
2. Searching for a grammatical form shows a grammar dictionary table card
3. Searching for an abbreviation (e.g., "adj") shows an abbreviation card with green border and details
4. Searching for a help term shows a help card with green border
5. Searching for an English word that has EPD entries shows an EPD card
6. Searching for a word with variant readings shows a variants table card
7. Searching for a misspelled word shows a spelling correction card
8. Searching for a word with cross-references shows a "see" card
9. All cards respect light/dark theme and user font size
10. Result ordering matches the webapp: headwords → roots → abbreviations → deconstructor → grammar → help → EPD → variants → spelling → see
11. No UI regressions in existing headword/root display

## Out of Scope

- Audio playback / IPA transcription fixes
- Bold definitions search tab
- RPD (Reverse Pali Dictionary) entries
- Sinhala/Devanagari/Thai script columns
- Clickable cross-references within cards (tapping a headword in "see" to navigate — future enhancement)
- Manual variant data (sourced from a TSV file, not the lookup table)
- Existing headword section gaps (frequency/feedback in AccordionCard/EntryScreen)
