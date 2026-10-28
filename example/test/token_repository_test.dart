import 'package:example_flutter/core/platform/example_native_api.dart';
import 'package:example_flutter/features/push_tokens/data/token_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:sendsay/sendsay.dart';

class FakeNativeApi implements ExampleNativeApi {
  int tokenCalls = 0;
  Exception? failure;

  @override
  Future<ExampleResources> getResources() async => (androidNotifications: null);

  @override
  Future<String> getPushToken() async {
    tokenCalls++;
    if (failure != null) throw failure!;
    return 'provider-token';
  }
}

class RecordingSendsay extends SendsayPlugin {
  String? token;

  @override
  Future<void> trackPushToken(String token) async {
    this.token = token;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final flavor in ['fcm', 'hms', 'rsm']) {
    test('$flavor retrieves token through the native API interface', () async {
      final nativeApi = FakeNativeApi();
      final repository = TokenRepository(
        flavor: flavor,
        platform: TargetPlatform.android,
        sendsay: SendsayPlugin(),
        nativeApi: nativeApi,
      );
      expect(await repository.getToken(), 'provider-token');
      expect(nativeApi.tokenCalls, 1);
    });
  }

  test('unknown flavor fails before calling native API', () async {
    final nativeApi = FakeNativeApi();
    final repository = TokenRepository(
      flavor: null,
      platform: TargetPlatform.android,
      sendsay: SendsayPlugin(),
      nativeApi: nativeApi,
    );
    await expectLater(repository.getToken(), throwsUnsupportedError);
    expect(nativeApi.tokenCalls, 0);
  });

  test('native errors reach the caller', () async {
    final failure = Exception('provider unavailable');
    final repository = TokenRepository(
      flavor: 'hms',
      platform: TargetPlatform.android,
      sendsay: SendsayPlugin(),
      nativeApi: FakeNativeApi()..failure = failure,
    );
    await expectLater(repository.getToken(), throwsA(same(failure)));
  });
  test('iOS retrieves APNs without an Android flavor and tracks it', () async {
    final nativeApi = FakeNativeApi();
    final sdk = RecordingSendsay();
    final repository = TokenRepository(
      flavor: null,
      platform: TargetPlatform.iOS,
      sendsay: sdk,
      nativeApi: nativeApi,
    );
    expect(repository.providerLabel, 'APNs');
    final token = await repository.getToken();
    await repository.trackToken(token);
    expect(nativeApi.tokenCalls, 1);
    expect(sdk.token, token);
  });
}
