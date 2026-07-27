import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/widgets/dict_html_card.dart';

/// Fixtures are the exact `definition_html` values stored in the mobile
/// database. DPPN puts alternative names, variant readings and reference
/// numbers on the head line; those belong in the displayed title, and the
/// body must not start with the punctuation left behind.
void main() {
  group('dppnDisplayTitle', () {
    test('appends an alternative name after its comma', () {
      const html =
          '<p><span class="Head">, <b>Abhitatta</b>. </span>'
          'A king of the race of <b>Mahā Sammata</b>. </p>';
      expect(dppnDisplayTitle('Ajitajana', html), 'Ajitajana, Abhitatta.');
    });

    test('appends a variant reading, dropping the leading full stop', () {
      const html =
          '<p><span class="Head">. (<i>v.l.</i> <b>Aṭṭakaraṇasutta</b>). </span>'
          '<b>Pasenadi</b> tells the Buddha how, whenever. </p>';
      expect(
        dppnDisplayTitle('Atthakaraṇasutta', html),
        'Atthakaraṇasutta. (v.l. Aṭṭakaraṇasutta).',
      );
    });

    test('appends a source reference with a space', () {
      const html =
          '<p><span class="Head"> (<abbr title="Added">Ja 90</abbr>). </span>'
          'A merchant is befriended by a colleague. </p>';
      expect(
        dppnDisplayTitle('Akataññujātaka', html),
        'Akataññujātaka (Ja 90).',
      );
    });

    test('appends a disambiguating number', () {
      const html =
          '<p><span class="Head"> 01. </span>A banker of Sāvatthī. </p>';
      expect(dppnDisplayTitle('Anāthapiṇḍika', html), 'Anāthapiṇḍika 01.');
    });

    test('leaves the title alone when there is no head span', () {
      const html = '<p>See <b>Akitti</b>. </p>';
      expect(dppnDisplayTitle('Akatti', html), 'Akatti');
    });

    test('drops a head span holding nothing but punctuation', () {
      // A stray doubled full stop carries no information, so the title stays
      // bare rather than gaining a trailing dot.
      const html = '<p><span class="Head">.. </span>The chief disciple. </p>';
      expect(dppnDisplayTitle('Khaṇḍa', html), 'Khaṇḍa');
    });

    test('body drops the head span so it no longer starts with punctuation', () {
      const html =
          '<p><span class="Head">, <b>Abhitatta</b>. </span>A king. </p>';
      expect(prepareDictHtml('dppn', html), '<p>A king. </p>');
    });

    test('other dictionaries are untouched by the dppn path', () {
      const html = '<p><span class="Head">, <b>x</b>. </span>body</p>';
      expect(prepareDictHtml('cpd', html), html);
    });
  });
}
