/// Returns [text] with sandhi apostrophes removed when [show] is false.
///
/// Sandhi apostrophes in Pāḷi are represented as a straight apostrophe (')
/// in text like `mahā'pi`, `y'eva`. When [show] is false they are stripped.
String filterApostrophe(String text, {required bool show}) {
  if (show) return text;
  return text.replaceAll("'", '');
}

enum NiggahitaFilterMode { dot, circle }

/// Substitutes niggahīta characters based on [mode].
///
/// When [mode] is [NiggahitaFilterMode.dot], text is returned unchanged (ṃ).
/// When [mode] is [NiggahitaFilterMode.circle], ṃ→ṁ and Ṃ→Ṁ.
String filterNiggahita(String text, {required NiggahitaFilterMode mode}) {
  if (mode == NiggahitaFilterMode.dot) return text;
  return text.replaceAll('ṃ', 'ṁ').replaceAll('Ṃ', 'Ṁ');
}
