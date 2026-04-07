import 'package:indic_transliteration_dart/indic_transliteration_dart.dart'
    as itr;

void initTransliteration() {
  itr.initializeSchemes();
}

/// Converts [input] to Roman (IAST) by auto-detecting the source script.
///
/// Returns [input] unchanged if it is already IAST or unrecognised.
/// Falls back to [input] unchanged on any package error.
String toRoman(String input) {
  if (input.isEmpty) return input;
  // Pure ASCII has no Brahmic or diacritic characters — nothing to convert.
  // Velthuis sequences (aa, .t, ~n) are already converted live before this runs.
  if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(input)) return input;
  try {
    final detected = itr.detect(input);
    if (detected == 'iast') return input;
    return itr.transliterate(input, fromScheme: detected, toScheme: 'iast');
  } catch (_) {
    return input;
  }
}
