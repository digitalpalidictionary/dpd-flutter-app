import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../providers/database_update_provider.dart';
import '../services/database_update_service.dart';
import '../theme/dpd_colors.dart';

class DownloadScreen extends ConsumerWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(dbUpdateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitle = _subtitleFor(updateState);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  isDark
                      ? 'assets/images/dpd-logo-dark.svg'
                      : 'assets/images/dpd-logo.svg',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Digital Pāḷi Dictionary',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                _buildContent(context, ref, updateState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DbUpdateState updateState,
  ) {
    final theme = Theme.of(context);

    switch (updateState.status) {
      case DbStatus.checking:
        return const SizedBox.shrink();

      case DbStatus.noDatabase:
        return Column(
          children: [
            Text(
              'The DPD database is required before the app can open. Download it when you are ready.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(dbUpdateProvider.notifier).startInitialDownload(),
              icon: const Icon(Icons.download),
              label: const Text('Download now'),
            ),
          ],
        );

      case DbStatus.downloading:
        return _downloadingView(context, updateState, updateState.progress);

      case DbStatus.extracting:
        return _downloadingView(
          context,
          updateState,
          1.0,
          label: 'Extracting…',
        );

      case DbStatus.error:
        return Column(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              updateState.errorMessage ?? 'An error occurred.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(dbUpdateProvider.notifier).checkForUpdates(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        );

      case DbStatus.ready:
        return const SizedBox.shrink();
    }
  }

  Widget _downloadingView(
    BuildContext context,
    DbUpdateState updateState,
    double percent, {
    String? label,
  }) {
    final theme = Theme.of(context);
    final release = updateState.releaseInfo;
    final service = DatabaseUpdateService();

    final statusLabel =
        label ??
        'Downloading database… ${(percent * 100).toStringAsFixed(0)}%'
            '${release != null ? "  (${service.formatBytes(release.size)})" : ""}';

    return Column(
      children: [
        LinearPercentIndicator(
          lineHeight: 12,
          percent: percent.clamp(0.0, 1.0),
          backgroundColor: theme.colorScheme.outlineVariant,
          progressColor: DpdColors.primary,
          barRadius: const Radius.circular(6),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        Text(statusLabel, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  String? _subtitleFor(DbUpdateState updateState) {
    switch (updateState.status) {
      case DbStatus.checking:
      case DbStatus.ready:
        return null;
      case DbStatus.noDatabase:
        return null;
      case DbStatus.downloading:
      case DbStatus.extracting:
        return 'Downloading the latest dictionary database…';
      case DbStatus.error:
        return 'Action is required before the app can open.';
    }
  }
}
