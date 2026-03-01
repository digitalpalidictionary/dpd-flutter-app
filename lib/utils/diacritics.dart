/// Strips Pāḷi diacritical marks to plain ASCII for search matching.
///
/// Uses a direct rune map rather than NFD normalization — faster and
/// correct for the closed Pāḷi character set.
String stripDiacritics(String text) {
  final clean = text.replaceAll('√', '').replaceAll(' ', '');
  final buffer = StringBuffer();
  for (final rune in clean.runes) {
    buffer.write(_diacriticMap[rune] ?? String.fromCharCode(rune));
  }
  return buffer.toString();
}

const _diacriticMap = <int, String>{
  0x0101: 'a', // ā
  0x012B: 'i', // ī
  0x016B: 'u', // ū
  0x1E45: 'n', // ṅ
  0x00F1: 'n', // ñ
  0x1E6D: 't', // ṭ
  0x1E0D: 'd', // ḍ
  0x1E47: 'n', // ṇ
  0x1E41: 'm', // ṁ
  0x1E43: 'm', // ṃ
  0x1E37: 'l', // ḷ
  0x1E25: 'h', // ḥ
  // Uppercase variants
  0x0100: 'A', // Ā
  0x012A: 'I', // Ī
  0x016A: 'U', // Ū
  0x1E44: 'N', // Ṅ
  0x00D1: 'N', // Ñ
  0x1E6C: 'T', // Ṭ
  0x1E0C: 'D', // Ḍ
  0x1E46: 'N', // Ṇ
  0x1E40: 'M', // Ṁ
  0x1E42: 'M', // Ṃ
  0x1E36: 'L', // Ḷ
  0x1E24: 'H', // Ḥ
};
