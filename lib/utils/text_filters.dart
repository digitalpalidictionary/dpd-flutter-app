/// Returns [text] with sandhi apostrophes removed when [show] is false.
///
/// Sandhi apostrophes in Pāḷi are represented as a straight apostrophe (')
/// in text like `mahā'pi`, `y'eva`. When [show] is false they are stripped.
String filterApostrophe(String text, {required bool show}) {
  if (show) return text;
  return text.replaceAll("'", '');
}
