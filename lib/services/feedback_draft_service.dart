import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';

const _contactKey = 'feedback_contact';
const _draftKey = 'feedback_draft';

class FeedbackDraft {
  const FeedbackDraft({
    this.name = '',
    this.email = '',
    this.issueType = '',
    this.description = '',
    this.improvement = '',
  });

  final String name;
  final String email;
  final String issueType;
  final String description;
  final String improvement;

  FeedbackDraft copyWith({
    String? name,
    String? email,
    String? issueType,
    String? description,
    String? improvement,
  }) {
    return FeedbackDraft(
      name: name ?? this.name,
      email: email ?? this.email,
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      improvement: improvement ?? this.improvement,
    );
  }
}

class FeedbackDraftService {
  FeedbackDraftService(this._prefs);

  final SharedPreferences _prefs;

  FeedbackDraft load() {
    final name = _prefs.getString('$_contactKey.name') ?? '';
    final email = _prefs.getString('$_contactKey.email') ?? '';
    final issueType = _prefs.getString('$_draftKey.issueType') ?? '';
    final description = _prefs.getString('$_draftKey.description') ?? '';
    final improvement = _prefs.getString('$_draftKey.improvement') ?? '';
    return FeedbackDraft(
      name: name,
      email: email,
      issueType: issueType,
      description: description,
      improvement: improvement,
    );
  }

  Future<void> save(FeedbackDraft draft) async {
    await Future.wait([
      _prefs.setString('$_contactKey.name', draft.name),
      _prefs.setString('$_contactKey.email', draft.email),
      _prefs.setString('$_draftKey.issueType', draft.issueType),
      _prefs.setString('$_draftKey.description', draft.description),
      _prefs.setString('$_draftKey.improvement', draft.improvement),
    ]);
  }

  Future<void> clearTransientDraft() async {
    await Future.wait([
      _prefs.remove('$_draftKey.issueType'),
      _prefs.remove('$_draftKey.description'),
      _prefs.remove('$_draftKey.improvement'),
    ]);
  }
}

final feedbackDraftServiceProvider = Provider<FeedbackDraftService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FeedbackDraftService(prefs);
});
