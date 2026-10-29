import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sendsay/sendsay.dart';
import 'package:sendsay/src/data/encoder/configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.sendsay');
  const segmentationChannel = MethodChannel('com.sendsay/segmentation_data');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  final plugin = SendsayPlugin();
  Object? response;
  PlatformException? platformError;

  setUpAll(() {
    // The platform subscribes to this stream when first constructed.
    messenger.setMockMethodCallHandler(segmentationChannel, (_) async => null);
  });

  setUp(() {
    calls.clear();
    response = null;
    platformError = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (platformError != null) {
        throw platformError!;
      }
      return response;
    });
  });

  tearDownAll(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(segmentationChannel, null);
  });

  void expectCall(String method, [Object? arguments]) {
    expect(calls, hasLength(1));
    expect(calls.single.method, method);
    expect(calls.single.arguments, arguments);
  }

  group('push provider routing through the public API', () {
    final methods = <String, Future<void> Function(String)>{
      'trackPushToken': plugin.trackPushToken,
      'trackHmsPushToken': plugin.trackHmsPushToken,
      'trackRsmPushToken': plugin.trackRsmPushToken,
      'handlePushToken': plugin.handlePushToken,
      'handleHmsPushToken': plugin.handleHmsPushToken,
      'handleRsmPushToken': plugin.handleRsmPushToken,
    };

    for (final entry in methods.entries) {
      test(entry.key, () async {
        await entry.value('provider-specific-token');
        expectCall(entry.key, 'provider-specific-token');
      });
    }
  });

  group('advertising identifiers', () {
    final methods = <String, Future<String?> Function()>{
      'getGAID': plugin.getGAID,
      'getIDFA': plugin.getIDFA,
      'fetchIDFA': plugin.fetchIDFA,
    };

    for (final entry in methods.entries) {
      test('${entry.key} preserves an unavailable result', () async {
        expect(await entry.value(), isNull);
        expectCall(entry.key);
      });

      test('${entry.key} returns the native identifier', () async {
        response = '12345678-1234-1234-1234-123456789abc';
        expect(await entry.value(), response);
        expectCall(entry.key);
      });
    }

    test('trackGAID submits a request without a return value', () async {
      await plugin.trackGAID();
      expectCall('trackGAID');
    });

    test('trackGAID propagates a native configuration error', () async {
      platformError = PlatformException(
        code: 'SendsayPlugin',
        message: 'SDK is not configured',
      );
      await expectLater(
        plugin.trackGAID(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'SendsayPlugin',
          ),
        ),
      );
      expectCall('trackGAID');
    });

    test('fetchGAID reports the native SDK limitation', () async {
      platformError = PlatformException(code: 'unsupported_operation');
      await expectLater(
        plugin.fetchGAID(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'unsupported_operation',
          ),
        ),
      );
      expectCall('fetchGAID');
    });

    test('trackIDFA submits a request without a return value', () async {
      await plugin.trackIDFA();
      expectCall('trackIDFA');
    });

    test('unsupported platforms propagate an explicit error', () async {
      platformError = PlatformException(
        code: 'unsupported_platform',
        message: 'getGAID is available only on Android.',
      );
      await expectLater(
        plugin.getGAID(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'unsupported_platform',
          ),
        ),
      );
    });

    test('ATT configuration errors are not converted into a null ID', () async {
      platformError = PlatformException(code: 'invalid_configuration');
      await expectLater(
        plugin.fetchIDFA(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'invalid_configuration',
          ),
        ),
      );
    });
  });

  group('integration lifecycle', () {
    test('stopIntegration invokes the native operation', () async {
      await plugin.stopIntegration();
      expectCall('stopIntegration');
    });

    test('clearLocalCustomerData passes the exact iOS App Group', () async {
      await plugin.clearLocalCustomerData(appGroup: 'group.example.sdk');
      expectCall('clearLocalCustomerData', {'appGroup': 'group.example.sdk'});
    });

    test(
      'clearLocalCustomerData allows Android to omit the App Group',
      () async {
        await plugin.clearLocalCustomerData();
        expectCall('clearLocalCustomerData', {'appGroup': null});
      },
    );

    test('a lifecycle error is delivered to the caller', () async {
      platformError = PlatformException(code: 'SendsayPlugin');
      await expectLater(
        plugin.stopIntegration(),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  test(
    'existing SSEC payload survives the public API and channel unchanged',
    () async {
      final payload = <String, dynamic>{
        'type': 'ssec_order',
        'data': {
          'transactionId': 'order-42',
          'transactionSum': 125.5,
          'items': [
            {'productId': 'product-1', 'price': 125.5, 'count': 1},
          ],
        },
      };
      await plugin.trackSSECEvent(payload);
      expectCall('trackSSECEvent', payload);
    },
  );

  group('Android GAID configuration', () {
    for (final enabled in [true, false]) {
      test('preserves an explicit $enabled value', () {
        final config = AndroidSendsayConfiguration(isGAIDEnabled: enabled);
        final encoded = AndroidSendsayConfigurationEncoder.encode(config);
        expect(encoded['isGAIDEnabled'], enabled);
        expect(
          AndroidSendsayConfigurationEncoder.decode(encoded).isGAIDEnabled,
          enabled,
        );
      });
    }

    test(
      'omits an unspecified policy instead of overriding native defaults',
      () {
        final encoded = AndroidSendsayConfigurationEncoder.encode(
          const AndroidSendsayConfiguration(),
        );
        expect(encoded.containsKey('isGAIDEnabled'), isFalse);
        expect(
          AndroidSendsayConfigurationEncoder.decode(encoded).isGAIDEnabled,
          isNull,
        );
      },
    );
  });
}
