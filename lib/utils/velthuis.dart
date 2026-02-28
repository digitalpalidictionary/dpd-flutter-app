String velthuis(String input) {
  return input
      .replaceAll('aa', 'ā')
      .replaceAll('ii', 'ī')
      .replaceAll('uu', 'ū')
      .replaceAll('"n', 'ṅ')
      .replaceAll('~n', 'ñ')
      .replaceAll('.t', 'ṭ')
      .replaceAll('.d', 'ḍ')
      .replaceAll('.n', 'ṇ')
      .replaceAll('.m', 'ṃ')
      .replaceAll('.l', 'ḷ')
      .replaceAll('.h', 'ḥ');
}
