import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_update_provider.dart';
import '../services/database_update_service.dart';
import '../theme/dpd_colors.dart';

class DownloadFooter extends ConsumerWidget {
  const DownloadFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(dbUpdateProvider);
    final theme = Theme.of(context);

    final status = updateState.status;
    if (status != DbStatus.downloading && status != DbStatus.extracting) {
      return const SizedBox.shrink();
    }

    final percent = updateState.progress.clamp(0.0, 1.0);
    final release = updateState.releaseInfo;
    final sizeLabel = release != null
        ? ' (${DatabaseUpdateService.formatBytes(release.size)})'
        : '';
    final label = status == DbStatus.extracting
        ? 'Applying update…'
        : 'Downloading database… ${(percent * 100).toStringAsFixed(0)}%$sizeLabel';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: status == DbStatus.extracting ? null : percent,
          backgroundColor: theme.colorScheme.outlineVariant,
          color: DpdColors.primary,
          minHeight: 3,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
