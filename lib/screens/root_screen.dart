import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/family_data.dart';
import '../providers/database_provider.dart';
import '../theme/dpd_colors.dart';
import '../widgets/entry_content.dart';
import '../widgets/family_section_builders.dart';
import '../widgets/family_table.dart';
import '../widgets/feedback_type.dart';
import '../widgets/root_info_table.dart';
import '../widgets/root_matrix_table.dart';
import '../widgets/feedback_footer.dart';

final _rootProvider = FutureProvider.autoDispose
    .family<RootWithFamilies?, String>((ref, rootKey) {
      return ref.watch(daoProvider).getRootWithFamilies(rootKey);
    });

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key, required this.rootKey});

  final String rootKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootAsync = ref.watch(_rootProvider(rootKey));

    return rootAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (rwf) {
        if (rwf == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Root not found')),
          );
        }
        return _RootView(rwf: rwf);
      },
    );
  }
}

class _RootView extends ConsumerStatefulWidget {
  const _RootView({required this.rwf});

  final RootWithFamilies rwf;

  @override
  ConsumerState<_RootView> createState() => _RootViewState();
}

class _RootViewState extends ConsumerState<_RootView> {
  String? _activeSection;

  String get _rootClean => widget.rwf.root.root.replaceAll('√', '');

  @override
  Widget build(BuildContext context) {
    // Eagerly start loading bases and root matrix in background
    ref.watch(basesForRootProvider(widget.rwf.root.root));
    ref.watch(rootMatrixProvider(widget.rwf.root.root));

    final theme = Theme.of(context);
    final root = widget.rwf.root;
    final families = widget.rwf.families;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    final boldStyle = baseStyle?.copyWith(fontWeight: FontWeight.w700);
    final grayStyle = baseStyle?.copyWith(color: DpdColors.gray);

    return Scaffold(
      bottomNavigationBar: const FeedbackFooter(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'root: $_rootClean',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  root.rootMeaning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary box
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: DpdColors.borderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: baseStyle,
                      children: [
                        const TextSpan(text: 'root. '),
                        TextSpan(text: _rootClean, style: boldStyle),
                        if (root.rootHasVerb.isNotEmpty)
                          TextSpan(
                            text: root.rootHasVerb,
                            style: baseStyle?.copyWith(
                              fontSize: (baseStyle.fontSize ?? 14) * 0.7,
                              fontFeatures: [const FontFeature.superscripts()],
                            ),
                          ),
                        TextSpan(text: ' ${root.rootGroup} '),
                        TextSpan(text: root.rootSign),
                        TextSpan(text: ' (${root.rootMeaning})'),
                        TextSpan(
                          text: ' ${widget.rwf.count}',
                          style: grayStyle,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Button row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    children: [
                      if (true)
                        DpdSectionButton(
                          label: 'root info',
                          isActive: _activeSection == 'info',
                          onTap: () => _toggle('info'),
                        ),
                      if ((root.rootCount ?? 0) > 0)
                        DpdSectionButton(
                          label: 'root matrix',
                          isActive: _activeSection == 'matrix',
                          onTap: () => _toggle('matrix'),
                        ),
                      for (final fam in families)
                        DpdSectionButton(
                          label: fam.rootFamily,
                          isActive: _activeSection == fam.rootFamilyKey,
                          onTap: () => _toggle(fam.rootFamilyKey),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Content sections
                if (_activeSection == 'info' && true) _buildRootInfoSection(),

                if (_activeSection == 'matrix' && (root.rootCount ?? 0) > 0)
                  _buildRootMatrixSection(),

                for (final fam in families)
                  if (_activeSection == fam.rootFamilyKey)
                    _buildFamilySection(fam),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(String section) {
    setState(() {
      _activeSection = _activeSection == section ? null : section;
    });
  }

  Widget _buildRootInfoSection() {
    final root = widget.rwf.root;
    final basesAsync = ref.watch(basesForRootProvider(root.root));
    final bases = basesAsync.whenOrNull(data: (b) => b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RootInfoTable(root: root, bases: bases),
    );
  }

  Widget _buildRootMatrixSection() {
    final root = widget.rwf.root;
    final matrixAsync = ref.watch(rootMatrixProvider(root.root));
    final matrix = matrixAsync.whenOrNull(data: (m) => m);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: matrix != null
          ? RootMatrixTable(root: root.root, data: matrix)
          : DpdSectionContainer(
              child: Padding(
                padding: DpdColors.sectionPadding,
                child: const CircularProgressIndicator(),
              ),
            ),
    );
  }

  Widget _buildFamilySection(FamilyRootData fam) {
    return FamilyTableWidget(
      header: buildRootFamilyHeader(context, fam),
      entries: parseFamilyData(fam.data),
      footerConfig: FamilyFooterConfig(
        messagePrefix: 'Something out of place?',
        linkText: 'Report it here',
        feedbackType: FeedbackType.rootFamily,
        word: widget.rwf.root.root,
      ),
    );
  }
}
