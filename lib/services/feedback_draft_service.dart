import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';

const _contactKey = 'feedback_contact';
const _draftKey = 'feedback_draft';
const _dpdDraftKey = 'dpd_feedback_draft';
const _addWordDraftKey = 'add_word_draft';
const _conjugationDraftKey = 'conjugation_draft';
const _declensionDraftKey = 'declension_draft';

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

class DpdFeedbackDraft {
  const DpdFeedbackDraft({
    this.name = '',
    this.email = '',
    this.suggestion = '',
    this.canonicalSentence = '',
    this.references = '',
  });

  final String name;
  final String email;
  final String suggestion;
  final String canonicalSentence;
  final String references;
}

class DeclensionDraft {
  const DeclensionDraft({
    this.name = '',
    this.email = '',
    this.headword = '',
    this.problem = const [],
    this.gender = const [],
    this.grammarCase = const [],
    this.number = const [],
    this.suggestion = '',
    this.example = '',
    this.comment = '',
  });

  final String name;
  final String email;
  final String headword;
  final List<String> problem;
  final List<String> gender;
  final List<String> grammarCase;
  final List<String> number;
  final String suggestion;
  final String example;
  final String comment;
}

class ConjugationDraft {
  const ConjugationDraft({
    this.name = '',
    this.email = '',
    this.headword = '',
    this.problem = const [],
    this.where = const [],
    this.voice = const [],
    this.person = const [],
    this.number = const [],
    this.suggestion = '',
    this.example = '',
    this.comment = '',
  });

  final String name;
  final String email;
  final String headword;
  final List<String> problem;
  final List<String> where;
  final List<String> voice;
  final List<String> person;
  final List<String> number;
  final String suggestion;
  final String example;
  final String comment;
}

class AddWordDraft {
  const AddWordDraft({
    this.name = '',
    this.email = '',
    this.headword = '',
    this.partOfSpeech = '',
    this.meaning = '',
    this.construction = '',
    this.example = '',
    this.source = '',
    this.note = '',
  });

  final String name;
  final String email;
  final String headword;
  final String partOfSpeech;
  final String meaning;
  final String construction;
  final String example;
  final String source;
  final String note;
}

class FeedbackDraftService {
  FeedbackDraftService(this._prefs);

  final SharedPreferences _prefs;

  String _getString(String key) => _prefs.getString(key) ?? '';

  Future<void> _saveContact({required String name, required String email}) {
    return Future.wait([
      _prefs.setString('$_contactKey.name', name),
      _prefs.setString('$_contactKey.email', email),
    ]);
  }

  List<String> _loadCsv(String key) {
    final value = _getString(key);
    return value.isEmpty ? [] : value.split(',');
  }

  Future<void> _removeKeys(List<String> keys) {
    return Future.wait(keys.map(_prefs.remove));
  }

  FeedbackDraft load() {
    final name = _getString('$_contactKey.name');
    final email = _getString('$_contactKey.email');
    final issueType = _getString('$_draftKey.issueType');
    final description = _getString('$_draftKey.description');
    final improvement = _getString('$_draftKey.improvement');
    return FeedbackDraft(
      name: name,
      email: email,
      issueType: issueType,
      description: description,
      improvement: improvement,
    );
  }

  Future<void> save(FeedbackDraft draft) async {
    await _saveContact(name: draft.name, email: draft.email);
    await Future.wait([
      _prefs.setString('$_draftKey.issueType', draft.issueType),
      _prefs.setString('$_draftKey.description', draft.description),
      _prefs.setString('$_draftKey.improvement', draft.improvement),
    ]);
  }

  Future<void> clearTransientDraft() async {
    await _removeKeys([
      '$_draftKey.issueType',
      '$_draftKey.description',
      '$_draftKey.improvement',
    ]);
  }

  DpdFeedbackDraft loadDpdDraft() {
    return DpdFeedbackDraft(
      name: _getString('$_contactKey.name'),
      email: _getString('$_contactKey.email'),
      suggestion: _getString('$_dpdDraftKey.suggestion'),
      canonicalSentence: _getString('$_dpdDraftKey.canonicalSentence'),
      references: _getString('$_dpdDraftKey.references'),
    );
  }

  Future<void> saveDpdDraft(DpdFeedbackDraft draft) async {
    await _saveContact(name: draft.name, email: draft.email);
    await Future.wait([
      _prefs.setString('$_dpdDraftKey.suggestion', draft.suggestion),
      _prefs.setString(
          '$_dpdDraftKey.canonicalSentence', draft.canonicalSentence),
      _prefs.setString('$_dpdDraftKey.references', draft.references),
    ]);
  }

  Future<void> clearDpdTransientDraft() async {
    await _removeKeys([
      '$_dpdDraftKey.suggestion',
      '$_dpdDraftKey.canonicalSentence',
      '$_dpdDraftKey.references',
    ]);
  }

  AddWordDraft loadAddWordDraft() {
    return AddWordDraft(
      name: _getString('$_contactKey.name'),
      email: _getString('$_contactKey.email'),
      headword: _getString('$_addWordDraftKey.headword'),
      partOfSpeech: _getString('$_addWordDraftKey.partOfSpeech'),
      meaning: _getString('$_addWordDraftKey.meaning'),
      construction: _getString('$_addWordDraftKey.construction'),
      example: _getString('$_addWordDraftKey.example'),
      source: _getString('$_addWordDraftKey.source'),
      note: _getString('$_addWordDraftKey.note'),
    );
  }

  Future<void> saveAddWordDraft(AddWordDraft draft) async {
    await _saveContact(name: draft.name, email: draft.email);
    await Future.wait([
      _prefs.setString('$_addWordDraftKey.headword', draft.headword),
      _prefs.setString('$_addWordDraftKey.partOfSpeech', draft.partOfSpeech),
      _prefs.setString('$_addWordDraftKey.meaning', draft.meaning),
      _prefs.setString('$_addWordDraftKey.construction', draft.construction),
      _prefs.setString('$_addWordDraftKey.example', draft.example),
      _prefs.setString('$_addWordDraftKey.source', draft.source),
      _prefs.setString('$_addWordDraftKey.note', draft.note),
    ]);
  }

  DeclensionDraft loadDeclensionDraft() {
    return DeclensionDraft(
      name: _getString('$_contactKey.name'),
      email: _getString('$_contactKey.email'),
      headword: _getString('$_declensionDraftKey.headword'),
      problem: _loadCsv('$_declensionDraftKey.problem'),
      gender: _loadCsv('$_declensionDraftKey.gender'),
      grammarCase: _loadCsv('$_declensionDraftKey.grammarCase'),
      number: _loadCsv('$_declensionDraftKey.number'),
      suggestion: _getString('$_declensionDraftKey.suggestion'),
      example: _getString('$_declensionDraftKey.example'),
      comment: _getString('$_declensionDraftKey.comment'),
    );
  }

  Future<void> saveDeclensionDraft(DeclensionDraft draft) async {
    await _saveContact(name: draft.name, email: draft.email);
    await Future.wait([
      _prefs.setString('$_declensionDraftKey.headword', draft.headword),
      _prefs.setString(
          '$_declensionDraftKey.problem', draft.problem.join(',')),
      _prefs.setString(
          '$_declensionDraftKey.gender', draft.gender.join(',')),
      _prefs.setString(
          '$_declensionDraftKey.grammarCase', draft.grammarCase.join(',')),
      _prefs.setString(
          '$_declensionDraftKey.number', draft.number.join(',')),
      _prefs.setString(
          '$_declensionDraftKey.suggestion', draft.suggestion),
      _prefs.setString('$_declensionDraftKey.example', draft.example),
      _prefs.setString('$_declensionDraftKey.comment', draft.comment),
    ]);
  }

  Future<void> clearDeclensionTransientDraft() async {
    await _removeKeys([
      '$_declensionDraftKey.headword',
      '$_declensionDraftKey.problem',
      '$_declensionDraftKey.gender',
      '$_declensionDraftKey.grammarCase',
      '$_declensionDraftKey.number',
      '$_declensionDraftKey.suggestion',
      '$_declensionDraftKey.example',
      '$_declensionDraftKey.comment',
    ]);
  }

  ConjugationDraft loadConjugationDraft() {
    return ConjugationDraft(
      name: _getString('$_contactKey.name'),
      email: _getString('$_contactKey.email'),
      headword: _getString('$_conjugationDraftKey.headword'),
      problem: _loadCsv('$_conjugationDraftKey.problem'),
      where: _loadCsv('$_conjugationDraftKey.where'),
      voice: _loadCsv('$_conjugationDraftKey.voice'),
      person: _loadCsv('$_conjugationDraftKey.person'),
      number: _loadCsv('$_conjugationDraftKey.number'),
      suggestion: _getString('$_conjugationDraftKey.suggestion'),
      example: _getString('$_conjugationDraftKey.example'),
      comment: _getString('$_conjugationDraftKey.comment'),
    );
  }

  Future<void> saveConjugationDraft(ConjugationDraft draft) async {
    await _saveContact(name: draft.name, email: draft.email);
    await Future.wait([
      _prefs.setString('$_conjugationDraftKey.headword', draft.headword),
      _prefs.setString(
          '$_conjugationDraftKey.problem', draft.problem.join(',')),
      _prefs.setString('$_conjugationDraftKey.where', draft.where.join(',')),
      _prefs.setString('$_conjugationDraftKey.voice', draft.voice.join(',')),
      _prefs.setString(
          '$_conjugationDraftKey.person', draft.person.join(',')),
      _prefs.setString(
          '$_conjugationDraftKey.number', draft.number.join(',')),
      _prefs.setString('$_conjugationDraftKey.suggestion', draft.suggestion),
      _prefs.setString('$_conjugationDraftKey.example', draft.example),
      _prefs.setString('$_conjugationDraftKey.comment', draft.comment),
    ]);
  }

  Future<void> clearConjugationTransientDraft() async {
    await _removeKeys([
      '$_conjugationDraftKey.headword',
      '$_conjugationDraftKey.problem',
      '$_conjugationDraftKey.where',
      '$_conjugationDraftKey.voice',
      '$_conjugationDraftKey.person',
      '$_conjugationDraftKey.number',
      '$_conjugationDraftKey.suggestion',
      '$_conjugationDraftKey.example',
      '$_conjugationDraftKey.comment',
    ]);
  }

  Future<void> clearAddWordTransientDraft() async {
    await _removeKeys([
      '$_addWordDraftKey.headword',
      '$_addWordDraftKey.partOfSpeech',
      '$_addWordDraftKey.meaning',
      '$_addWordDraftKey.construction',
      '$_addWordDraftKey.example',
      '$_addWordDraftKey.source',
      '$_addWordDraftKey.note',
    ]);
  }
}

final feedbackDraftServiceProvider = Provider<FeedbackDraftService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FeedbackDraftService(prefs);
});
