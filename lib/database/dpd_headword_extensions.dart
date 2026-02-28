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

  /// Placeholder for Python-dependent conversion
  String get lemmaTradClean => '';

  /// Placeholder for Python-dependent conversion
  String get lemmaIpa => '';
}
