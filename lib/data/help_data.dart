import 'package:flutter/services.dart';

// ── Bibliography ──────────────────────────────────────────────────────────────

class BibliographyEntry {
  final String surname;
  final String firstname;
  final String title;
  final String year;
  final String publisher;
  final String city;
  final String site;

  const BibliographyEntry({
    required this.surname,
    required this.firstname,
    required this.title,
    required this.year,
    required this.publisher,
    required this.city,
    required this.site,
  });
}

class BibliographyCategory {
  final String name;
  final List<BibliographyEntry> entries;

  const BibliographyCategory({required this.name, required this.entries});
}

// ── Thanks ────────────────────────────────────────────────────────────────────

class ThanksEntry {
  final String who;
  final String where;
  final String what;

  const ThanksEntry({
    required this.who,
    required this.where,
    required this.what,
  });
}

class ThanksCategory {
  final String name;
  final String description;
  final List<ThanksEntry> entries;

  const ThanksCategory({
    required this.name,
    required this.description,
    required this.entries,
  });
}

// ── TSV parsing ───────────────────────────────────────────────────────────────

List<String> _parseTsvRow(String row) {
  return row.split('\t').map((cell) {
    cell = cell.trim();
    if (cell.length >= 2 && cell.startsWith('"') && cell.endsWith('"')) {
      cell = cell.substring(1, cell.length - 1);
    } else if (cell.startsWith('"')) {
      // Lone or unmatched opening quote — artifact of multiline quoted cells
      // split across lines; treat as empty or strip the stray quote.
      cell = cell.length == 1 ? '' : cell.substring(1);
    }
    return cell;
  }).toList();
}

String _col(List<String> cells, int i) => i < cells.length ? cells[i] : '';

List<BibliographyCategory> parseBibliographyTsv(String tsv) {
  // columns: category(0), surname(1), firstname(2), title(3), book(4),
  //          journal(5), page_range(6), edited_by(7), doi(8), year(9),
  //          publisher(10), city(11), site(12)
  final categories = <BibliographyCategory>[];
  final lines = tsv.split('\n');
  List<BibliographyEntry>? currentEntries;
  bool isHeader = true;

  for (final line in lines) {
    if (isHeader) {
      isHeader = false;
      continue;
    }
    final cells = _parseTsvRow(line);
    if (cells.every((c) => c.isEmpty)) continue;

    final category = _col(cells, 0);
    final surname = _col(cells, 1);
    final firstname = _col(cells, 2);
    final title = _col(cells, 3);
    final year = _col(cells, 9);
    final publisher = _col(cells, 10);
    final city = _col(cells, 11);
    final site = _col(cells, 12);

    if (category.isNotEmpty) {
      currentEntries = [];
      categories.add(
        BibliographyCategory(name: category, entries: currentEntries),
      );
    }

    final hasData = surname.isNotEmpty || title.isNotEmpty;
    if (hasData && currentEntries != null) {
      currentEntries.add(
        BibliographyEntry(
          surname: surname,
          firstname: firstname,
          title: title,
          year: year,
          publisher: publisher,
          city: city,
          site: site,
        ),
      );
    }
  }

  return categories;
}

List<ThanksCategory> parseThanksTsv(String tsv) {
  // columns: category(0), who(1), where(2), what(3)
  final categories = <ThanksCategory>[];
  final lines = tsv.split('\n');
  List<ThanksEntry>? currentEntries;
  bool isHeader = true;

  for (final line in lines) {
    if (isHeader) {
      isHeader = false;
      continue;
    }
    final cells = _parseTsvRow(line);
    if (cells.every((c) => c.isEmpty)) continue;

    final category = _col(cells, 0);
    final who = _col(cells, 1);
    final where = _col(cells, 2);
    final what = _col(cells, 3);

    if (category.isNotEmpty) {
      currentEntries = [];
      categories.add(
        ThanksCategory(name: category, description: what, entries: currentEntries),
      );
    } else if (who.isNotEmpty && currentEntries != null) {
      currentEntries.add(ThanksEntry(who: who, where: where, what: what));
    }
  }

  return categories;
}

// ── File loaders ──────────────────────────────────────────────────────────────

Future<List<BibliographyCategory>> loadBibliography() async {
  final content = await rootBundle.loadString('assets/help/bibliography.tsv');
  return parseBibliographyTsv(content);
}

Future<List<ThanksCategory>> loadThanks() async {
  final content = await rootBundle.loadString('assets/help/thanks.tsv');
  return parseThanksTsv(content);
}
