import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/widgets/dict_html_card.dart';

void main() {
  test('prepareDictHtml converts CPD h2 tags to inline bold markup', () {
    const html = '<p>before <h2>Grammar</h2> after</p>';

    final result = prepareDictHtml('cpd', html);

    expect(result, '<p>before <strong>Grammar</strong> after</p>');
  });

  test('prepareDictHtml leaves non-CPD h2 tags unchanged', () {
    const html = '<p>before <h2>Grammar</h2> after</p>';

    final result = prepareDictHtml('mw', html);

    expect(result, html);
  });
}
