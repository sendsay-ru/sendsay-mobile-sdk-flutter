import 'package:example_flutter/features/push_tokens/data/token_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sendsay/sendsay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.sendsay.example/tokens');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  for (final flavor in ['fcm', 'hms', 'rsm']) {
    test('$flavor retrieves token through the native bridge', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getToken');
        return 'provider-token';
      });
      final repository = TokenRepository(
        flavor: flavor,
        sendsay: SendsayPlugin(),
      );
      expect(await repository.getToken(), 'provider-token');
    });
  }

  test('empty token is an explicit failure', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => '  ');
    final repository = TokenRepository(flavor: 'fcm', sendsay: SendsayPlugin());
    await expectLater(repository.getToken(), throwsA(isA<PlatformException>()));
  });

  test('unknown flavor fails before calling the bridge', () async {
    final repository = TokenRepository(flavor: null, sendsay: SendsayPlugin());
    await expectLater(repository.getToken(), throwsUnsupportedError);
  });

  test('provider errors reach the caller', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'token_unavailable');
    });
    final repository = TokenRepository(flavor: 'hms', sendsay: SendsayPlugin());
    await expectLater(repository.getToken(), throwsA(isA<PlatformException>()));
  });
}
