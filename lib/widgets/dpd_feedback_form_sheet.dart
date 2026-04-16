import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/feedback_draft_service.dart';
import '../utils/date_utils.dart';
import '../utils/feedback_urls.dart';
import 'feedback_form_components.dart';

const _sectionValues = [
  'Meaning',
  'Sutta',
  'Grammar',
  'Examples',
  'Root Family',
  'Word Family',
  'Compound Family',
  'Idioms',
  'Set',
  'Frequency',
  'Root Info',
  'Root Matrix',
  'Deconstructor',
  'Other',
];

Future<void> showDpdFeedbackSheet(
  BuildContext context, {
  String? headword,
  int? headwordId,
  String? feedbackType,
}) {
  return showFeedbackBottomSheet(
    context,
    builder: (context) {
      return _DpdFeedbackFormSheet(
        headword: headword,
        headwordId: headwordId,
        feedbackType: feedbackType,
      );
    },
  );
}

class _DpdFeedbackFormSheet extends ConsumerStatefulWidget {
  const _DpdFeedbackFormSheet({
    this.headword,
    this.headwordId,
    this.feedbackType,
  });

  final String? headword;
  final int? headwordId;
  final String? feedbackType;

  @override
  ConsumerState<_DpdFeedbackFormSheet> createState() =>
      _DpdFeedbackFormSheetState();
}

class _DpdFeedbackFormSheetState extends ConsumerState<_DpdFeedbackFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _headwordCtrl;
  late final TextEditingController _suggestionCtrl;
  late final TextEditingController _canonicalCtrl;
  late final TextEditingController _referencesCtrl;
  late final TextEditingController _featureCtrl;
  late final TextEditingController _betterCtrl;

  String? _section;
  bool _submitting = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(feedbackDraftServiceProvider).loadDpdDraft();
    _nameCtrl = TextEditingController(text: draft.name);
    _emailCtrl = TextEditingController(text: draft.email);

    final hw = widget.headword ?? '';
    _headwordCtrl = TextEditingController(
      text: widget.headwordId != null ? '${widget.headwordId} $hw' : hw,
    );

    _suggestionCtrl = TextEditingController(text: draft.suggestion);
    _canonicalCtrl = TextEditingController(text: draft.canonicalSentence);
    _referencesCtrl = TextEditingController(text: draft.references);
    _featureCtrl = TextEditingController();
    _betterCtrl = TextEditingController();

    _section =
        widget.feedbackType != null &&
                _sectionValues.contains(widget.feedbackType)
            ? widget.feedbackType
            : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _headwordCtrl.dispose();
    _suggestionCtrl.dispose();
    _canonicalCtrl.dispose();
    _referencesCtrl.dispose();
    _featureCtrl.dispose();
    _betterCtrl.dispose();
    super.dispose();
  }

  DpdFeedbackDraft _currentDraft() => DpdFeedbackDraft(
    name: _nameCtrl.text,
    email: _emailCtrl.text,
    suggestion: _suggestionCtrl.text,
    canonicalSentence: _canonicalCtrl.text,
    references: _referencesCtrl.text,
  );

  void _saveDraft() {
    ref.read(feedbackDraftServiceProvider).saveDpdDraft(_currentDraft());
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

      final version = dpdAppLabel();
      final headword = _headwordCtrl.text;
      final section = _section ?? '';

      bool launched;
      if (isOnline) {
        final url = buildMistakeUrl(
          word: headword.isNotEmpty ? headword : null,
          feedbackType: section.isNotEmpty ? section : null,
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          suggestion: _suggestionCtrl.text,
          canonicalSentence: _canonicalCtrl.text,
          references: _referencesCtrl.text,
          feature: _featureCtrl.text,
          better: _betterCtrl.text,
        );
        launched = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        final uri = buildMistakeEmailUri(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          headword: headword,
          section: section,
          suggestion: _suggestionCtrl.text,
          canonicalSentence: _canonicalCtrl.text,
          references: _referencesCtrl.text,
          feature: _featureCtrl.text,
          better: _betterCtrl.text,
          version: version,
        );
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (launched) {
        await ref.read(feedbackDraftServiceProvider).clearDpdTransientDraft();
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
                    Text('DPD Feedback', style: theme.textTheme.titleLarge),
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
                    autovalidateMode:
                        _submitted
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
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                            validator:
                                (v) =>
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
                            decoration: const InputDecoration(border: InputBorder.none),
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
                              'Please check that the spelling is exactly the same as it currently appears.',
                          required: true,
                          child: TextFormField(
                            controller: _headwordCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Headword is required'
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What section is the problem in?',
                          required: true,
                          child: DropdownButtonFormField<String>(
                            initialValue: _section,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            hint: const Text('Choose'),
                            items:
                                _sectionValues
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {
                              setState(() => _section = v);
                              _saveDraft();
                            },
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Please select a section'
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What is your suggestion to correct it?',
                          required: true,
                          child: TextFormField(
                            controller: _suggestionCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Suggestion is required'
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question:
                              'Please provide a canonical sentence with the word in context.',
                          subText: 'Add n/a if not applicable.',
                          required: true,
                          child: TextFormField(
                            controller: _canonicalCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'This field is required'
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question:
                              'Can you provide reasons or reference from other sources?',
                          subText:
                              'e.g. Pāli texts, other dictionaries, grammar books etc.',
                          child: TextFormField(
                            controller: _referencesCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What feature of DPD is most useful to you?',
                          child: TextFormField(
                            controller: _featureCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What would make DPD better for you?',
                          child: TextFormField(
                            controller: _betterCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
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
                            child:
                                _submitting
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
