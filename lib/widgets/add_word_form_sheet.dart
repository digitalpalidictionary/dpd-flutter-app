import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/feedback_draft_service.dart';
import '../utils/date_utils.dart';
import '../utils/feedback_urls.dart';
import 'feedback_form_components.dart';

const _posValues = [
  'adj: adjective',
  'aor: aorist verb',
  'card: cardinal number',
  'cond: conditional verb',
  'cs: conjugation sign',
  'fem: feminine noun',
  'fut: future verb',
  'ger: gerund verb',
  'idiom: idiomatic phrase',
  'imp: imperative verb',
  'imperf: imperfect verb',
  'ind: indeclineable nipāta',
  'inf: infinitive verb',
  'letter: letter of the alphabet',
  'masc: masculine noun',
  'nt: neuter noun',
  'opt: optative verb',
  'ordin: ordinal number',
  'perf: perfect verb',
  'pp: past participle',
  'pr: present tense verb',
  'prefix: beginning affix',
  'pron: pronoun',
  'prp: present participle',
  'ptp: potential participle',
  'root: root / dhātu',
  'sandhi: sandhi compound',
  'suffix: ending affix',
  've: verbal ending',
];

Future<void> showAddWordSheet(BuildContext context) {
  return showFeedbackBottomSheet(
    context,
    builder: (context) => const _AddWordFormSheet(),
  );
}

class _AddWordFormSheet extends ConsumerStatefulWidget {
  const _AddWordFormSheet();

  @override
  ConsumerState<_AddWordFormSheet> createState() => _AddWordFormSheetState();
}

class _AddWordFormSheetState extends ConsumerState<_AddWordFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _headwordCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _constructionCtrl;
  late final TextEditingController _exampleCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _noteCtrl;

  String? _pos;
  bool _submitting = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(feedbackDraftServiceProvider).loadAddWordDraft();
    _nameCtrl = TextEditingController(text: draft.name);
    _emailCtrl = TextEditingController(text: draft.email);
    _headwordCtrl = TextEditingController(text: draft.headword);
    _meaningCtrl = TextEditingController(text: draft.meaning);
    _constructionCtrl = TextEditingController(text: draft.construction);
    _exampleCtrl = TextEditingController(text: draft.example);
    _sourceCtrl = TextEditingController(text: draft.source);
    _noteCtrl = TextEditingController(text: draft.note);
    _pos = draft.partOfSpeech.isNotEmpty ? draft.partOfSpeech : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _headwordCtrl.dispose();
    _meaningCtrl.dispose();
    _constructionCtrl.dispose();
    _exampleCtrl.dispose();
    _sourceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  AddWordDraft _currentDraft() => AddWordDraft(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        headword: _headwordCtrl.text,
        partOfSpeech: _pos ?? '',
        meaning: _meaningCtrl.text,
        construction: _constructionCtrl.text,
        example: _exampleCtrl.text,
        source: _sourceCtrl.text,
        note: _noteCtrl.text,
      );

  void _saveDraft() {
    ref.read(feedbackDraftServiceProvider).saveAddWordDraft(_currentDraft());
  }

  Future<void> _submit() async {
    if (_submitting) return;

    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline =
          !connectivity.contains(ConnectivityResult.none) &&
          connectivity.isNotEmpty;

      bool launched;
      if (isOnline) {
        final url = buildAddWordUrl(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          headword: _headwordCtrl.text,
          partOfSpeech: _pos,
          meaning: _meaningCtrl.text,
          construction: _constructionCtrl.text,
          example: _exampleCtrl.text,
          source: _sourceCtrl.text,
          note: _noteCtrl.text,
        );
        launched = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        final uri = buildAddWordEmailUri(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          headword: _headwordCtrl.text,
          partOfSpeech: _pos ?? '',
          meaning: _meaningCtrl.text,
          construction: _constructionCtrl.text,
          example: _exampleCtrl.text,
          source: _sourceCtrl.text,
          note: _noteCtrl.text,
          version: dpdAppLabel(),
        );
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (launched) {
        await ref
            .read(feedbackDraftServiceProvider)
            .clearAddWordTransientDraft();
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage =
              'Could not open the ${isOnline ? 'browser' : 'mail app'}. Please try again.';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                child: Row(
                  children: [
                    Text('Add a Word', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: FeedbackRequiredFieldLabel(),
                        ),
                        const SizedBox(height: 8),
                        FeedbackQuestionCard(
                          question: 'Name',
                          required: true,
                          child: TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'Email Address',
                          required: true,
                          child: TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(v.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What is the headword?',
                          subText:
                              'For nouns, pronouns and participles use the vocative singular.\n'
                              'For verbs use the 3rd person sg.\n'
                              'For indeclinables, sandhi and idioms, use the exact form found in texts.',
                          child: TextFormField(
                            controller: _headwordCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What is the part of speech?',
                          subText:
                              'Please select one from the drop-down list below.',
                          child: DropdownButtonFormField<String>(
                            initialValue: _pos,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            hint: const Text('Choose'),
                            isExpanded: true,
                            items: _posValues
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _pos = v);
                              _saveDraft();
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What is the meaning?',
                          subText:
                              'Add the English meaning of the word in this context.\n'
                              'Add a synonym for clarity.\n'
                              'Separate synonyms using semi-colons.',
                          required: true,
                          child: TextFormField(
                            controller: _meaningCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Meaning is required'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'How is the word constructed?',
                          subText:
                              'For words derived from roots, show the prefix(es) + root + suffix(es).\n'
                              'For compounds, show component + component.\n'
                              'Please take a look at DPD Grammar tab for typical constructions.',
                          child: TextFormField(
                            controller: _constructionCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textCapitalization: TextCapitalization.none,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'Example sentence',
                          subText:
                              'Copy and paste the sentence in which the word is found.',
                          child: TextFormField(
                            controller: _exampleCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'Source',
                          subText:
                              'In which book is this sentence found? Please mention non-canonical references like chanting and grammar books.',
                          child: TextFormField(
                            controller: _sourceCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'Note',
                          subText: 'Please add any further notes of interest.',
                          child: TextFormField(
                            controller: _noteCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => _saveDraft(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'Version',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              dpdAppLabel(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text('Send'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
