import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hasInternetProvider = FutureProvider<bool>((ref) async {
  try {
    await Dio().head<void>(
      'https://dpdict.net',
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    return true;
  } catch (_) {
    return false;
  }
});
