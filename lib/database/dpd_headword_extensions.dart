import 'package:dpd_flutter_app/database/database.dart';

extension DpdHeadwordGrammar on DpdHeadword {
  /// Regex cleanup of lemma_1 (removes numbers at the end)
  String get lemmaClean {
    return lemma1.replaceAll(
      RegExp(r' \d.*$', multiLine: true, unicode: true),
      '',
    );
  }

  /// Regex cleanup of root_key (removes numbers at the end)
  String get rootClean {
    if (rootKey == null) return '';
    return rootKey!.replaceAll(
      RegExp(r' \d.*$', multiLine: true, unicode: true),
      '',
    );
  }

  /// Clean construction of all brackets and phonetic changes.
  /// Ported from dpd-db meaning_construction.py
  String cleanConstruction() {
    var c = construction ?? '';
    if (c.isEmpty) return '';

    // strip line 2
    c = c.replaceAll(RegExp(r'\n.*', multiLine: true, unicode: true), '');
    // remove > ... +
    c = c.replaceAllMapped(
      RegExp(r' >.+?( \+)', unicode: true),
      (match) => match.group(1)!,
    );
    // remove [] ... +
    c = c.replaceAllMapped(
      RegExp(r' \+ \[.+?( \+)', unicode: true),
      (match) => match.group(1)!,
    );
    // remove [] at beginning
    c = c.replaceAll(RegExp(r'^\[.+?( \+ )', unicode: true), '');
    // remove [] at end
    c = c.replaceAll(RegExp(r' \+ \[.*\]$', unicode: true), '');
    // remove ??
    c = c.replaceAll(RegExp(r'\?\? ', unicode: true), '');

    return c;
  }

  /// Compile grammar line
  /// Ported from dpd-db meaning_construction.py make_grammar_line
  String get grammarLine {
    String g = grammar ?? '';

    if (neg != null && neg!.isNotEmpty) {
      g += g.isEmpty ? neg! : ', $neg';
    }
    if (verb != null && verb!.isNotEmpty) {
      g += g.isEmpty ? verb! : ', $verb';
    }
    if (trans != null && trans!.isNotEmpty) {
      g += g.isEmpty ? trans! : ', $trans';
    }
    if (plusCase != null && plusCase!.isNotEmpty) {
      g += g.isEmpty ? '($plusCase)' : ' ($plusCase)';
    }

    return g;
  }

  /// Traditional lemma endings map - ported from dpd-db/tools/lemma_traditional.py
  static const Map<String, String> _lemmaTradDict = {
    'ant adj': 'antu',
    'ant masc': 'antu',
    'ar fem': 'u',
    'ar masc': 'u',
    'ar2 masc': 'u',
    'arahant masc': 'arahanta',
    'as masc': 'a',
    'bhavant masc': 'bhavantu',
    'mātar fem': 'mātu',
  };

  /// Traditional lemma - ported from dpd-db/tools/lemma_traditional.py
  String get lemmaTradClean {
    final p = pattern;
    final s = stem;

    // Only process lemmas, not inflected forms (! in stem indicates inflected)
    if (p != null &&
        s != null &&
        !s.contains('!') &&
        _lemmaTradDict.containsKey(p)) {
      final ending = _lemmaTradDict[p]!;
      final trad = '$s$ending'.replaceAll('!', '').replaceAll('*', '');
      return trad;
    }

    return lemmaClean;
  }

  /// Ported from dpd-db tools/meaning_construction.py summarize_construction()
  String get constructionSummary {
    var c = (construction ?? '').replaceAll('<b>', '').replaceAll('</b>', '');

    // if no meaning then show root, word family or nothing
    if ((meaning1 == null || meaning1!.isEmpty) &&
        origin != 'pass1' &&
        origin != 'pass2') {
      if (rootKey != null && rootKey!.isNotEmpty) {
        return (familyRoot ?? '').replaceAll(' ', ' + ');
      } else if (familyWord != null && familyWord!.isNotEmpty) {
        return familyWord!;
      } else {
        return '';
      }
    }

    if ((meaning1 != null && meaning1!.isNotEmpty) ||
        ((meaning1 == null || meaning1!.isEmpty) &&
            (origin == 'pass1' || origin == 'pass2'))) {
      if (construction == null || construction!.isEmpty) return '';

      // remove line2
      c = c.replaceAll(RegExp(r'\n.+$', unicode: true), '');
      // remove phonetic changes
      c = c.replaceAll(RegExp(r'> .[^ ]*? ', unicode: true), '');
      // remove phonetic changes at end
      c = c.replaceAll(RegExp(r' > .[^ ]*?$', unicode: true), '');
      // remove brackets
      c = c.replaceAll('(', '').replaceAll(')', '');
      // remove [insertions]
      c = c.replaceAll(
        RegExp(r'^\[.*\] \+| \[.*\] \+| \+ \[.*\]$', unicode: true),
        '',
      );

      if (rootBase == null || rootBase!.isEmpty) {
        return c.isEmpty ? '' : c;
      }

      // cleanup the base and base_construction
      final baseClean =
          rootBase!.replaceAll(RegExp(r' \(.+\)$', unicode: true), '');
      final base = baseClean.replaceAllMapped(
        RegExp(r'(.+ )(.+?$)', unicode: true),
        (m) => m.group(2)!,
      );
      var baseConstruction = baseClean.replaceAllMapped(
        RegExp(r'(.+)( > .+?$)', unicode: true),
        (m) => m.group(1)!,
      );
      baseConstruction =
          baseConstruction.replaceAll(RegExp(r' >.*', unicode: true), '');

      if (pos != 'fut') {
        final rootSignPlus = (rootSign ?? '').replaceAll(' ', ' + ');
        final rootPlusSign = '$rootClean + $rootSignPlus';
        c = c.replaceAll(base, rootPlusSign);
      } else {
        c = c.replaceAll(base, baseConstruction);
      }
      return c;
    }

    return '';
  }

  /// Ported from dpd-db tools/degree_of_completion.py
  String get degreeOfCompletion {
    if (meaning1 != null && meaning1!.isNotEmpty) {
      if (source1 != null && source1!.isNotEmpty) {
        return '✔';
      } else {
        return '◑';
      }
    } else {
      return '✘';
    }
  }

  /// IPA transcription - PLACEHOLDER until added to DB
  /// When building DB: use Aksharamukha transliterate.process("IASTPali", "IPA", lemma_clean)
  /// See tables.dart for DB computed field note
  String get lemmaIpa => '';
}
