import 'package:example_flutter/core/platform/example_native_api.dart';
import 'package:example_flutter/features/push_tokens/data/token_repository.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final flavor in ['fcm', 'hms', 'rsm']) {
    test('$flavor retrieves token through the native API interface', () async {
      final nativeApi = FakeNativeApi();
      final repository = TokenRepository(
        flavor: flavor,
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
      sendsay: SendsayPlugin(),
      nativeApi: FakeNativeApi()..failure = failure,
    );
    await expectLater(repository.getToken(), throwsA(same(failure)));
  });
}
