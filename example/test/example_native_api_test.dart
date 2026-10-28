import 'package:example_flutter/core/platform/method_channel_example_native_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.sendsay.example/native');
  const reader = MethodChannelExampleNativeApi();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('reads resolved Android channel resources and icon', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getResources');
      return {
        'androidNotifications': {
          'channelId': 'flavor-channel',
          'channelName': 'Localized name',
          'channelDescription': 'Localized description',
          'icon': 123,
        },
      };
    });
    expect((await reader.getResources()).androidNotifications, (
      channelId: 'flavor-channel',
      channelName: 'Localized name',
      channelDescription: 'Localized description',
      icon: 123,
    ));
  });

  for (final invalid in <Map<String, Object>?>[
    null,
    {},
    {
      'channelId': '',
      'channelName': 'Name',
      'channelDescription': 'Description',
      'icon': 123,
    },
    {
      'channelId': 'id',
      'channelName': 'Name',
      'channelDescription': 'Description',
      'icon': 'invalid',
    },
  ]) {
    test('rejects invalid resources: $invalid', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => invalid == null ? null : {'androidNotifications': invalid},
      );
      await expectLater(
        reader.getResources(),
        throwsA(isA<PlatformException>()),
      );
    });
  }

  test('does not call Android channel on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(channel, (_) async {
      fail('Android channel must not be called on iOS');
    });
    expect((await reader.getResources()).androidNotifications, isNull);
  });

  test('token uses the same native channel', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getPushToken');
      return 'native-token';
    });
    expect(await reader.getPushToken(), 'native-token');
  });

  test('empty token fails explicitly', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => '  ');
    await expectLater(reader.getPushToken(), throwsA(isA<PlatformException>()));
  });

  test('iOS token retrieval is explicitly unsupported for now', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await expectLater(reader.getPushToken(), throwsUnsupportedError);
  });

  test('propagates native errors', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'resources_unavailable');
    });
    await expectLater(reader.getResources(), throwsA(isA<PlatformException>()));
  });
}
