import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sendsay/sendsay.dart';

import '../../../core/platform/example_native_api_provider.dart';
import '../data/token_repository.dart';

/// Repository selected by the build flavor, replaceable in tests.
final tokenRepositoryProvider = Provider<TokenRepository>((ref) {
  return TokenRepository(
    flavor: appFlavor,
    platform: defaultTargetPlatform,
    sendsay: SendsayPlugin(),
    nativeApi: ref.watch(exampleNativeApiProvider),
  );
});

/// Token operations and their loading/error state.
final tokenControllerProvider = AsyncNotifierProvider<TokenController, String?>(
  TokenController.new,
);

/// Keeps token retrieval and SDK calls outside widgets.
class TokenController extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  /// Retrieves a fresh token, optionally registering it with Sendsay.
  Future<void> refresh({bool track = false}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final repository = ref.read(tokenRepositoryProvider);
    final result = await AsyncValue.guard(() async {
      final token = await repository.getToken();
      if (track) await repository.trackToken(token);
      return token;
    });
    if (ref.mounted) state = result;
  }
}
