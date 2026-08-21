import 'package:flutter/widgets.dart';

/// Returns [text] with sandhi apostrophes removed when [show] is false.
///
/// Sandhi apostrophes in Pāḷi are represented as a straight apostrophe (')
/// in text like `mahā'pi`, `y'eva`. When [show] is false they are stripped.
String filterApostrophe(String text, {required bool show}) {
  if (show) return text;
  return text.replaceAll("'", '');
}

/// Substitutes niggahīta characters for display.
///
/// The database stores the dot form (ṃ) exclusively. When [circle] is true the
/// dot form is swapped for the circle form (ṁ) for display only — never for a
/// stored value, lookup key, or query.
String filterNiggahita(String text, {required bool circle}) {
  if (!circle) return text;
  return text.replaceAll('ṃ', 'ṁ').replaceAll('Ṃ', 'Ṁ');
}

/// Folds the circle form (ṁ) back to the canonical dot form (ṃ).
///
/// The inverse of [filterNiggahita]. Applied wherever displayed text re-enters
/// the data layer — a query, a history entry — so that only the dot form is
/// ever stored or searched, whichever form is on screen.
String canonicalNiggahita(String text) =>
    text.replaceAll('ṁ', 'ṃ').replaceAll('Ṁ', 'Ṃ');

/// Carries the user's niggahīta choice down the widget tree.
///
/// Installed once above `MaterialApp` so that plain [StatelessWidget]s deep in
/// the tree can honour the setting without each becoming a Riverpod consumer.
/// Dependents rebuild automatically when the choice changes.
class NiggahitaScope extends InheritedWidget {
  const NiggahitaScope({super.key, required this.circle, required super.child});

  final bool circle;

  /// Whether the circle form (ṁ) is currently chosen. Defaults to false when no
  /// scope is present, so widgets remain usable outside the app tree.
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NiggahitaScope>()?.circle ??
      false;

  @override
  bool updateShouldNotify(NiggahitaScope oldWidget) =>
      circle != oldWidget.circle;
}

extension NiggahitaContext on BuildContext {
  /// Applies the user's niggahīta choice to [text] for display.
  String nigg(String text) =>
      filterNiggahita(text, circle: NiggahitaScope.of(this));
}
