import 'date_utils.dart';

const _feedbackEmail = 'digitalpalidictionary@gmail.com';

void _addField(StringBuffer buffer, String entryId, String? value) {
  if (value != null && value.isNotEmpty) {
    buffer.write('&$entryId=${Uri.encodeComponent(value)}');
  }
}

void _addMultiField(StringBuffer buffer, String entryId, List<String> values) {
  for (final value in values) {
    buffer.write('&$entryId=${Uri.encodeComponent(value)}');
  }
}

Uri _buildEmailUri({
  required String subject,
  required List<String> lines,
}) {
  return Uri.parse(
    'mailto:$_feedbackEmail'
    '?subject=${Uri.encodeComponent(subject)}'
    '&body=${Uri.encodeComponent(lines.join('\n'))}',
  );
}

String buildMistakeUrl({
  String? word,
  int? headwordId,
  String? feedbackType,
  String? name,
  String? email,
  String? suggestion,
  String? canonicalSentence,
  String? references,
  String? feature,
  String? better,
}) {
  final appLabel = Uri.encodeComponent(dpdAppLabel());
  final url = StringBuffer(
    'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url',
  );

  _addField(url, 'entry.485428648', name);
  _addField(url, 'entry.781828361', email);

  if (word != null) {
    final encodedWord = Uri.encodeComponent(word);
    final wordIdentifier =
        headwordId != null ? '$headwordId%20$encodedWord' : encodedWord;
    url.write('&entry.438735500=$wordIdentifier');
  }

  _addField(url, 'entry.326955045', feedbackType);
  _addField(url, 'entry.644913945', suggestion);
  _addField(url, 'entry.852810955', canonicalSentence);
  _addField(url, 'entry.1765697356', references);
  _addField(url, 'entry.1696159737', feature);
  _addField(url, 'entry.702723139', better);

  url.write('&entry.1433863141=$appLabel');
  return url.toString();
}

Uri buildMistakeEmailUri({
  required String name,
  required String email,
  required String headword,
  required String section,
  required String suggestion,
  required String canonicalSentence,
  String references = '',
  String feature = '',
  String better = '',
  required String version,
}) {
  final subject = section.isNotEmpty ? 'DPD Feedback: $section' : 'DPD Feedback';

  final lines = <String>[
    'Name: $name',
    'Email: $email',
    'Headword: $headword',
    'Section: $section',
    'Suggestion: $suggestion',
    'Canonical sentence: $canonicalSentence',
    if (references.isNotEmpty) 'References: $references',
    if (feature.isNotEmpty) 'Feature: $feature',
    if (better.isNotEmpty) 'Better: $better',
    'Version: $version',
  ];

  return _buildEmailUri(subject: subject, lines: lines);
}

String buildAddWordUrl({
  String? name,
  String? email,
  String? headword,
  String? partOfSpeech,
  String? meaning,
  String? construction,
  String? example,
  String? source,
  String? note,
}) {
  final appLabel = Uri.encodeComponent(dpdAppLabel());
  final url = StringBuffer(
    'https://docs.google.com/forms/d/e/1FAIpQLSfResxEUiRCyFITWPkzoQ2HhHEvUS5fyg68Rl28hFH6vhHlaA/viewform?usp=pp_url',
  );

  _addField(url, 'entry.485428648', name);
  _addField(url, 'entry.1899964408', email);
  _addField(url, 'entry.438735500', headword);
  _addField(url, 'entry.454195331', partOfSpeech);
  _addField(url, 'entry.1336477674', meaning);
  _addField(url, 'entry.1479670965', construction);
  _addField(url, 'entry.1622508768', example);
  _addField(url, 'entry.1010992813', source);
  _addField(url, 'entry.386524957', note);
  url.write('&entry.1433863141=$appLabel');
  return url.toString();
}

String buildDeclensionUrl({
  String? name,
  String? email,
  String? headword,
  List<String> problem = const [],
  List<String> gender = const [],
  List<String> grammarCase = const [],
  List<String> number = const [],
  String? suggestion,
  String? example,
  String? comment,
}) {
  final appLabel = Uri.encodeComponent(dpdAppLabel());
  final url = StringBuffer(
    'https://docs.google.com/forms/d/e/1FAIpQLSfKUBx-icfRCWmhHqUwzX60BVQE21s_NERNfU2VvbjEfE371A/viewform?usp=pp_url',
  );

  _addField(url, 'entry.485428648', name);
  _addField(url, 'entry.879531967', email);
  _addField(url, 'entry.1370304754', headword);
  _addMultiField(url, 'entry.454961512', problem);
  _addMultiField(url, 'entry.851894358', gender);
  _addMultiField(url, 'entry.1969099896', grammarCase);
  _addMultiField(url, 'entry.1975788187', number);
  _addField(url, 'entry.47036326', suggestion);
  _addField(url, 'entry.229331961', example);
  _addField(url, 'entry.1696159737', comment);
  url.write('&entry.1433863141=$appLabel');
  return url.toString();
}

Uri buildDeclensionEmailUri({
  required String name,
  required String email,
  required String headword,
  required List<String> problem,
  required List<String> gender,
  required List<String> grammarCase,
  required List<String> number,
  required String suggestion,
  String example = '',
  String comment = '',
  required String version,
}) {
  String join(List<String> values) => values.join(', ');

  final lines = <String>[
    'Name: $name',
    'Email: $email',
    'Headword: $headword',
    if (problem.isNotEmpty) 'Problem: ${join(problem)}',
    if (gender.isNotEmpty) 'Gender: ${join(gender)}',
    if (grammarCase.isNotEmpty) 'Case: ${join(grammarCase)}',
    if (number.isNotEmpty) 'Number: ${join(number)}',
    'Suggestion: $suggestion',
    if (example.isNotEmpty) 'Example: $example',
    if (comment.isNotEmpty) 'Comment: $comment',
    'Version: $version',
  ];

  return _buildEmailUri(subject: 'DPD Declension Feedback', lines: lines);
}

String buildConjugationUrl({
  String? name,
  String? email,
  String? headword,
  List<String> problem = const [],
  List<String> where = const [],
  List<String> voice = const [],
  List<String> person = const [],
  List<String> number = const [],
  String? suggestion,
  String? example,
  String? comment,
}) {
  final appLabel = Uri.encodeComponent(dpdAppLabel());
  final url = StringBuffer(
    'https://docs.google.com/forms/d/e/1FAIpQLSdAL2PzavyrtXgGmtNrZAMyh3hV6g3fU0chxhWFxunQEZtH0g/viewform?usp=pp_url',
  );

  _addField(url, 'entry.485428648', name);
  _addField(url, 'entry.879531967', email);
  _addField(url, 'entry.1932605469', headword);
  _addMultiField(url, 'entry.1591633300', problem);
  _addMultiField(url, 'entry.581292522', where);
  _addMultiField(url, 'entry.1217382361', voice);
  _addMultiField(url, 'entry.65036028', person);
  _addMultiField(url, 'entry.1350348681', number);
  _addField(url, 'entry.952439603', suggestion);
  _addField(url, 'entry.1765697356', example);
  _addField(url, 'entry.1696159737', comment);
  url.write('&entry.1433863141=$appLabel');
  return url.toString();
}

Uri buildConjugationEmailUri({
  required String name,
  required String email,
  required String headword,
  required List<String> problem,
  required List<String> where,
  required List<String> voice,
  required List<String> person,
  required List<String> number,
  required String suggestion,
  String example = '',
  String comment = '',
  required String version,
}) {
  String join(List<String> values) => values.join(', ');

  final lines = <String>[
    'Name: $name',
    'Email: $email',
    'Headword: $headword',
    if (problem.isNotEmpty) 'Problem: ${join(problem)}',
    if (where.isNotEmpty) 'Where: ${join(where)}',
    if (voice.isNotEmpty) 'Voice: ${join(voice)}',
    if (person.isNotEmpty) 'Person: ${join(person)}',
    if (number.isNotEmpty) 'Number: ${join(number)}',
    'Suggestion: $suggestion',
    if (example.isNotEmpty) 'Example: $example',
    if (comment.isNotEmpty) 'Comment: $comment',
    'Version: $version',
  ];

  return _buildEmailUri(subject: 'DPD Conjugation Feedback', lines: lines);
}

Uri buildAddWordEmailUri({
  required String name,
  required String email,
  String headword = '',
  String partOfSpeech = '',
  required String meaning,
  String construction = '',
  String example = '',
  String source = '',
  String note = '',
  required String version,
}) {
  final lines = <String>[
    'Name: $name',
    'Email: $email',
    if (headword.isNotEmpty) 'Headword: $headword',
    if (partOfSpeech.isNotEmpty) 'Part of speech: $partOfSpeech',
    'Meaning: $meaning',
    if (construction.isNotEmpty) 'Construction: $construction',
    if (example.isNotEmpty) 'Example: $example',
    if (source.isNotEmpty) 'Source: $source',
    if (note.isNotEmpty) 'Note: $note',
    'Version: $version',
  ];

  return _buildEmailUri(subject: 'DPD Add a Word', lines: lines);
}
