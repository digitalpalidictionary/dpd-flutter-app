import 'pali_transliterator/pali_script.dart';
import 'pali_transliterator/pali_script_converter.dart';
import 'pali_transliterator/script_detector.dart';

void initTransliteration() {
  // No startup initialization required for the imported transliterator.
}

final _asciiRomanRegex = RegExp(r'^[a-zA-Z0-9.\s]+$');

String normalizeLookupQuery(String input) {
  return toRoman(input.trim());
}

/// Converts non-Roman input to Roman (IAST) for DB lookup.
///
/// Roman input is returned unchanged immediately.
/// Falls back to [input] unchanged on any converter error.
String toRoman(String input) {
  if (input.isEmpty) return input;
  if (_asciiRomanRegex.hasMatch(input)) return input;

  try {
    final detected = ScriptDetector.getLanguage(input);
    if (detected == Script.roman) return input;
    return PaliScript.getRomanScriptFrom(script: detected, text: input);
  } catch (_) {
    return input;
  }
}
