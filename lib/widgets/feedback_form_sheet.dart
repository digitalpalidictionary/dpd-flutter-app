import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/feedback_draft_service.dart';
import '../utils/app_feedback_url.dart';
import '../utils/feedback_email_draft.dart';
import 'feedback_form_components.dart';

const _issueTypes = [
  'App crash or freeze',
  'Display problem',
  'Feature request',
  'General feedback',
  'Other',
];

Future<void> showFeedbackFormSheet(
  BuildContext context, {
  required String? dbVersion,
}) {
  return showFeedbackBottomSheet(
    context,
    builder: (context) {
      return _FeedbackFormSheet(dbVersion: dbVersion);
    },
  );
}

class _FeedbackFormSheet extends ConsumerStatefulWidget {
  const _FeedbackFormSheet({required this.dbVersion});

  final String? dbVersion;

  @override
  ConsumerState<_FeedbackFormSheet> createState() => _FeedbackFormSheetState();
}

class _FeedbackFormSheetState extends ConsumerState<_FeedbackFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _improvementCtrl;

  String? _issueType;
  bool _submitting = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(feedbackDraftServiceProvider).load();
    _nameCtrl = TextEditingController(text: draft.name);
    _emailCtrl = TextEditingController(text: draft.email);
    _descriptionCtrl = TextEditingController(text: draft.description);
    _improvementCtrl = TextEditingController(text: draft.improvement);
    _issueType = draft.issueType.isNotEmpty ? draft.issueType : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _descriptionCtrl.dispose();
    _improvementCtrl.dispose();
    super.dispose();
  }

  FeedbackDraft _currentDraft() => FeedbackDraft(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        issueType: _issueType ?? '',
        description: _descriptionCtrl.text,
        improvement: _improvementCtrl.text,
      );

  void _saveDraft() {
    ref.read(feedbackDraftServiceProvider).save(_currentDraft());
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
      final meta = await collectFeedbackMetadata(dbVersion: widget.dbVersion);
      final draft = _currentDraft();

      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = !connectivity.contains(ConnectivityResult.none) &&
          connectivity.isNotEmpty;

      bool launched;
      if (isOnline) {
        final url = buildFeedbackUrlFromParams(
          platform: meta.platform,
          deviceModel: meta.deviceModel,
          osVersion: meta.osVersion,
          appVersion: meta.appVersion,
          dbVersion: meta.dbVersion,
          name: draft.name,
          email: draft.email,
          issueType: draft.issueType,
          description: draft.description,
          improvement: draft.improvement,
        );
        launched = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        final uri = buildFeedbackEmailUri(
          name: draft.name,
          email: draft.email,
          issueType: draft.issueType,
          description: draft.description,
          improvement: draft.improvement,
          metadata: meta,
        );
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (launched) {
        await ref.read(feedbackDraftServiceProvider).clearTransientDraft();
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = 'Could not open the ${isOnline ? 'browser' : 'mail app'}. Please try again.';
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
                    Text('Report a Problem', style: theme.textTheme.titleLarge),
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
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _saveDraft(),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'Email address',
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
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: "What's the issue?",
                          required: true,
                          child: DropdownButtonFormField<String>(
                            initialValue: _issueType,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            hint: const Text('Choose'),
                            items: _issueTypes
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _issueType = v);
                              _saveDraft();
                            },
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Please select an issue type' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'Description',
                          required: true,
                          child: TextFormField(
                            controller: _descriptionCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 3,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeedbackQuestionCard(
                          question: 'What would make the app better for you?',
                          child: TextFormField(
                            controller: _improvementCtrl,
                            decoration: const InputDecoration(border: InputBorder.none),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 3,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _saveDraft(),
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
