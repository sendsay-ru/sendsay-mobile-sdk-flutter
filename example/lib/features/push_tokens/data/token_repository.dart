import '../../../core/platform/example_native_api.dart';
import 'package:sendsay/sendsay.dart';

/// Accesses the example's flavor-specific Android push provider.
class TokenRepository {
  /// Allows replacing the bridge and SDK in tests.
  const TokenRepository({
    required this.flavor,
    required this.sendsay,
    required this.nativeApi,
  });

  final String? flavor;
  final SendsayPlugin sendsay;
  final ExampleNativeApi nativeApi;

  /// Retrieves a real token, rejecting unsupported flavors and empty results.
  Future<String> getToken() async {
    if (!['fcm', 'hms', 'rsm'].contains(flavor)) {
      throw UnsupportedError('Run the Android example with fcm, hms or rsm.');
    }
    return nativeApi.getPushToken();
  }

  /// Explicitly sends the current token to Sendsay on every call.
  Future<void> trackToken(String token) async {
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
