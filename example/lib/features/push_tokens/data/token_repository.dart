import 'package:flutter/foundation.dart';

import '../../../core/platform/example_native_api.dart';
import 'package:sendsay/sendsay.dart';

/// Retrieves Android provider or APNs tokens and tracks them in Sendsay.
class TokenRepository {
  /// Allows replacing the bridge and SDK in tests.
  const TokenRepository({
    required this.flavor,
    required this.sendsay,
    required this.nativeApi,
    required this.platform,
  });

  final String? flavor;
  final TargetPlatform platform;
  final SendsayPlugin sendsay;
  final ExampleNativeApi nativeApi;

  /// Human-readable provider name for the token card.
  String get providerLabel => platform == TargetPlatform.iOS
      ? 'APNs'
      : flavor?.toUpperCase() ?? 'Unknown';

  /// Retrieves a real token, rejecting unsupported flavors and empty results.
  Future<String> getToken() async {
    if (platform == TargetPlatform.iOS) return nativeApi.getPushToken();
    if (platform != TargetPlatform.android ||
        !['fcm', 'hms', 'rsm'].contains(flavor)) {
      throw UnsupportedError('Run the Android example with fcm, hms or rsm.');
    }
    return nativeApi.getPushToken();
  }

  /// Explicitly sends the current token to Sendsay on every call.
  Future<void> trackToken(String token) async {
    if (platform == TargetPlatform.iOS) {
      await sendsay.trackPushToken(token);
      return;
    }
    if (platform != TargetPlatform.android) {
      throw UnsupportedError('Push token tracking requires Android or iOS.');
    }
    switch (flavor) {
      case 'fcm':
        await sendsay.trackPushToken(token);
        return;
      case 'hms':
        await sendsay.trackHmsPushToken(token);
        return;
      case 'rsm':
        await sendsay.trackRsmPushToken(token);
        return;
      default:
        throw UnsupportedError('Unsupported push flavor: $flavor');
    }
  }
}
