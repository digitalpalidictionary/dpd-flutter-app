import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_update_provider.dart';
import '../providers/database_update_provider.dart';
import '../services/database_update_service.dart';
import '../theme/dpd_palette.dart';

class DownloadFooter extends ConsumerWidget {
  const DownloadFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(dbUpdateProvider);
    final appUpdate = ref.watch(appUpdateProvider);
    final theme = Theme.of(context);

    final status = updateState.status;
    final dbBusy =
        status == DbStatus.downloading || status == DbStatus.extracting;
    final appDownloading = appUpdate.status == AppUpdateStatus.downloading;
    if (!dbBusy && !appDownloading) {
      return const SizedBox.shrink();
    }

    final double? value;
    final String label;
    if (dbBusy) {
      final percent = updateState.progress.clamp(0.0, 1.0);
      final release = updateState.releaseInfo;
      final sizeLabel = release != null
          ? ' (${DatabaseUpdateService.formatBytes(release.size)})'
          : '';
      value = status == DbStatus.extracting ? null : percent;
      label = status == DbStatus.extracting
          ? 'Applying update…'
          : 'Downloading database… ${(percent * 100).toStringAsFixed(0)}%$sizeLabel';
    } else {
      final percent = appUpdate.progress.clamp(0.0, 1.0);
      final size = appUpdate.sizeBytes;
      final sizeLabel =
          size != null ? ' (${DatabaseUpdateService.formatBytes(size)})' : '';
      value = percent;
      label =
          'Downloading app update… ${(percent * 100).toStringAsFixed(0)}%$sizeLabel';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: value,
          backgroundColor: theme.colorScheme.outlineVariant,
          color: context.palette.primary,
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
