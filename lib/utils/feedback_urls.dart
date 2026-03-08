import 'date_utils.dart';

String buildMistakeUrl({
  String? word,
  int? headwordId,
  String? feedbackType,
}) {
  final appLabel = Uri.encodeComponent(dpdAppLabel());
  var url = 'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url';

  if (word != null) {
    final encodedWord = Uri.encodeComponent(word);
    final wordIdentifier = headwordId != null ? '$headwordId%20$encodedWord' : encodedWord;
    url += '&entry.438735500=$wordIdentifier';
  }

  if (feedbackType != null && feedbackType.isNotEmpty) {
    url += '&entry.326955045=${Uri.encodeComponent(feedbackType)}';
  }

  url += '&entry.1433863141=$appLabel';
  return url;
}

String buildAddWordUrl() {
  final appLabel = Uri.encodeComponent(dpdAppLabel());
  return 'https://docs.google.com/forms/d/e/1FAIpQLSfResxEUiRCyFITWPkzoQ2HhHEvUS5fyg68Rl28hFH6vhHlaA/viewform?usp=pp_url&entry.1433863141=$appLabel';
}
