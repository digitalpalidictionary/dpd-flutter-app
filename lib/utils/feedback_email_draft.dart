import 'app_feedback_url.dart';

const _feedbackEmail = 'digitalpalidictionary@gmail.com';

Uri buildFeedbackEmailUri({
  required String name,
  required String email,
  required String issueType,
  required String description,
  required String improvement,
  required FeedbackMetadata metadata,
}) {
  final subject = 'DPD App Feedback: $issueType';

  final body = [
    'Name: $name',
    'Email: $email',
    'Issue Type: $issueType',
    'Description: $description',
    if (improvement.isNotEmpty) 'Improvement: $improvement',
    'Platform: ${metadata.platform}',
    'Device: ${metadata.deviceModel}',
    'OS Version: ${metadata.osVersion}',
    'App Version: ${metadata.appVersion}',
    'Database Version: ${metadata.dbVersion ?? ''}',
  ].join('\n');

  return Uri.parse(
    'mailto:$_feedbackEmail'
    '?subject=${Uri.encodeComponent(subject)}'
    '&body=${Uri.encodeComponent(body)}',
  );
}
