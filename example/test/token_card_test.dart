import 'package:example_flutter/core/platform/example_native_api.dart';
import 'package:example_flutter/features/push_tokens/application/token_controller.dart';
import 'package:example_flutter/features/push_tokens/data/token_repository.dart';
import 'package:example_flutter/features/push_tokens/presentation/token_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sendsay/sendsay.dart';

class StubNativeApi implements ExampleNativeApi {
  @override
  Future<ExampleResources> getResources() async => (androidNotifications: null);

  @override
  Future<String> getPushToken() async => '00abff';
}

class RecordingSendsay extends SendsayPlugin {
  String? token;

  @override
  Future<void> trackPushToken(String token) async {
    this.token = token;
  }
}

void main() {
  testWidgets('APNs card retrieves, displays and tracks an iOS token', (
    tester,
  ) async {
    final sdk = RecordingSendsay();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenRepositoryProvider.overrideWithValue(
            TokenRepository(
              flavor: null,
              platform: TargetPlatform.iOS,
              sendsay: sdk,
              nativeApi: StubNativeApi(),
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TokenCard())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Push token · APNs'), findsOneWidget);
    await tester.tap(find.text('Get token'));
    await tester.pumpAndSettle();
    expect(find.text('00abff'), findsOneWidget);
    expect(sdk.token, isNull);
    await tester.tap(find.text('Send to Sendsay'));
    await tester.pumpAndSettle();
    expect(sdk.token, '00abff');
    expect(find.text('Token sent to Sendsay'), findsOneWidget);
  });
}
