import 'package:dpd_flutter_app/providers/app_update_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUpdateState', () {
    test('defaults carry no size or error', () {
      const initial = AppUpdateState();
      expect(initial.status, AppUpdateStatus.idle);
      expect(initial.sizeBytes, isNull);
      expect(initial.errorMessage, isNull);
    });

    test('copyWith sets sizeBytes when a download starts', () {
      const initial = AppUpdateState();
      final downloading = initial.copyWith(
        status: AppUpdateStatus.downloading,
        latestTag: 'v0.1.10',
        sizeBytes: 72409284,
        progress: 0,
      );
      expect(downloading.status, AppUpdateStatus.downloading);
      expect(downloading.sizeBytes, 72409284);
      expect(downloading.latestTag, 'v0.1.10');
    });

    test('copyWith into error preserves unrelated fields', () {
      final downloading = const AppUpdateState().copyWith(
        status: AppUpdateStatus.downloading,
        latestTag: 'v0.1.10',
        sizeBytes: 72409284,
        progress: 0.4,
      );
      final failed = downloading.copyWith(
        status: AppUpdateStatus.error,
        errorMessage: 'connection lost',
      );
      expect(failed.status, AppUpdateStatus.error);
      expect(failed.errorMessage, 'connection lost');
      expect(failed.sizeBytes, 72409284);
      expect(failed.latestTag, 'v0.1.10');
      expect(failed.progress, 0.4);
    });
  });
}
