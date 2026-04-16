import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/feedback_draft_service.dart';
import '../theme/dpd_colors.dart';
import '../utils/date_utils.dart';
import '../utils/feedback_urls.dart';
import 'feedback_form_components.dart';

Future<void> showDeclensionSheet(
  BuildContext context, {
  String? headword,
  int? headwordId,
}) {
  return showFeedbackBottomSheet(
    context,
    builder: (context) => _DeclensionFormSheet(
      headword: headword,
      headwordId: headwordId,
    ),
  );
}

class _DeclensionFormSheet extends ConsumerStatefulWidget {
  const _DeclensionFormSheet({this.headword, this.headwordId});

  final String? headword;
  final int? headwordId;

  @override
  ConsumerState<_DeclensionFormSheet> createState() =>
      _DeclensionFormSheetState();
}

class _DeclensionFormSheetState extends ConsumerState<_DeclensionFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _headwordCtrl;
  late final TextEditingController _suggestionCtrl;
  late final TextEditingController _exampleCtrl;
  late final TextEditingController _commentCtrl;

  late List<String> _problem;
  late List<String> _gender;
  late List<String> _grammarCase;
  late List<String> _number;

  bool _submitting = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(feedbackDraftServiceProvider).loadDeclensionDraft();
    _nameCtrl = TextEditingController(text: draft.name);
    _emailCtrl = TextEditingController(text: draft.email);

    final hw = widget.headword ?? '';
    _headwordCtrl = TextEditingController(
      text: widget.headwordId != null ? '${widget.headwordId} $hw' : hw,
    );

    _suggestionCtrl = TextEditingController(text: draft.suggestion);
    _exampleCtrl = TextEditingController(text: draft.example);
    _commentCtrl = TextEditingController(text: draft.comment);

    _problem = List.from(draft.problem);
    _gender = List.from(draft.gender);
    _grammarCase = List.from(draft.grammarCase);
    _number = List.from(draft.number);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _headwordCtrl.dispose();
    _suggestionCtrl.dispose();
    _exampleCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  DeclensionDraft _currentDraft() => DeclensionDraft(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        headword: _headwordCtrl.text,
        problem: _problem,
        gender: _gender,
        grammarCase: _grammarCase,
        number: _number,
        suggestion: _suggestionCtrl.text,
        example: _exampleCtrl.text,
        comment: _commentCtrl.text,
      );

  void _saveDraft() {
    ref
        .read(feedbackDraftServiceProvider)
        .saveDeclensionDraft(_currentDraft());
  }

  void _toggleValue(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
    _saveDraft();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    setState(() => _submitted = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    final checkboxesValid =
        _problem.isNotEmpty &&
        _gender.isNotEmpty &&
        _grammarCase.isNotEmpty &&
        _number.isNotEmpty;
    if (!formValid || !checkboxesValid) return;

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
        final url = buildDeclensionUrl(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          headword: _headwordCtrl.text,
          problem: _problem,
          gender: _gender,
          grammarCase: _grammarCase,
          number: _number,
          suggestion: _suggestionCtrl.text,
          example: _exampleCtrl.text,
          comment: _commentCtrl.text,
        );
        launched = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        final uri = buildDeclensionEmailUri(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          headword: _headwordCtrl.text,
          problem: _problem,
          gender: _gender,
          grammarCase: _grammarCase,
          number: _number,
          suggestion: _suggestionCtrl.text,
          example: _exampleCtrl.text,
          comment: _commentCtrl.text,
          version: dpdAppLabel(),
        );
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (launched) {
        await ref
            .read(feedbackDraftServiceProvider)
            .clearDeclensionTransientDraft();
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
                    Text(
                      'DPD Declension Tables',
                      style: theme.textTheme.titleLarge,
                    ),
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
                        // Form description
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(
                                DpdColors.borderRadiusValue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Please help to improve these tables by correcting mistakes and adding missing declensions.',
                                style: TextStyle(
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => launchUrl(
                                  Uri.parse(
                                      'https://digitalpalidictionary.github.io/'),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: Text(
                                  'For more information, visit digitalpalidictionary.github.io',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const FeedbackRequiredFieldLabel(),
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
                          question: 'What is the Pāli headword?',
                          required: true,
                          child: TextFormField(
                            controller: _headwordCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Headword is required'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackCheckboxCard(
                          question: 'What is the problem?',
                          required: true,
                          options: const [
                            'Missing declension',
                            'Wrong declension',
                            'Other',
                          ],
                          selected: _problem,
                          onToggle: (v) => _toggleValue(_problem, v),
                          submitted: _submitted,
                        ),
                        const SizedBox(height: 12),
                        FeedbackCheckboxCard(
                          question: 'What gender?',
                          required: true,
                          options: const [
                            'Masculine',
                            'Feminine',
                            'Neuter',
                            'Dual or X',
                          ],
                          selected: _gender,
                          onToggle: (v) => _toggleValue(_gender, v),
                          submitted: _submitted,
                        ),
                        const SizedBox(height: 12),
                        FeedbackCheckboxCard(
                          question: 'Which case?',
                          required: true,
                          options: const [
                            'Nominative',
                            'Accusative',
                            'Instrumental',
                            'Dative',
                            'Ablative',
                            'Genitive',
                            'Locative',
                            'Vocative',
                          ],
                          selected: _grammarCase,
                          onToggle: (v) => _toggleValue(_grammarCase, v),
                          submitted: _submitted,
                        ),
                        const SizedBox(height: 12),
                        FeedbackCheckboxCard(
                          question: 'Singular or Plural?',
                          required: true,
                          options: const ['Singular', 'Plural'],
                          selected: _number,
                          onToggle: (v) => _toggleValue(_number, v),
                          submitted: _submitted,
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What is your suggested correction?',
                          required: true,
                          child: TextFormField(
                            controller: _suggestionCtrl,
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            textCapitalization: TextCapitalization.none,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Suggestion is required'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question:
                              'Can you provide an example from a Pāli text?',
                          subText:
                              'An example from the Tipiṭaka would help to correct the problem. e.g. MN 12 takkapariyāhataṃ',
                          child: TextFormField(
                            controller: _exampleCtrl,
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
                          question: 'Any other comments or suggestions?',
                          child: TextFormField(
                            controller: _commentCtrl,
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
