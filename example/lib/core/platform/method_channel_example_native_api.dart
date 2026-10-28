import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'example_native_api.dart';

/// Owns the example's single native channel, wire format and validation.
class MethodChannelExampleNativeApi implements ExampleNativeApi {
  const MethodChannelExampleNativeApi([
    this._channel = const MethodChannel('com.sendsay.example/native'),
  ]);

  final MethodChannel _channel;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<ExampleResources> getResources() async {
    if (!_isAndroid) return (androidNotifications: null);
    final values = await _channel
        .invokeMapMethod<String, dynamic>('getResources')
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw PlatformException(
            code: 'resources_timeout',
            message: 'Native resources could not be loaded.',
          ),
        );
    final notifications = values?['androidNotifications'];
    if (notifications is! Map) throw _invalidResources();
    final channelId = notifications['channelId'];
    final channelName = notifications['channelName'];
    final channelDescription = notifications['channelDescription'];
    final icon = notifications['icon'];
    if (channelId is! String ||
        channelId.trim().isEmpty ||
        channelName is! String ||
        channelName.trim().isEmpty ||
        channelDescription is! String ||
        icon is! int ||
        icon == 0) {
      throw _invalidResources();
    }
    return (
      androidNotifications: (
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
        icon: icon,
      ),
    );
  }

  @override
  Future<String> getPushToken() async {
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      throw UnsupportedError('Push token retrieval requires Android or iOS.');
    }
    final token = await _channel
        .invokeMethod<String>('getPushToken')
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw PlatformException(
            code: 'token_timeout',
            message: 'The push provider did not return a token in time.',
          ),
        );
    if (token == null || token.trim().isEmpty) {
      throw PlatformException(
        code: 'token_unavailable',
        message: 'The push provider returned an empty token.',
      );
    }
    return token;
  }

  PlatformException _invalidResources() => PlatformException(
    code: 'invalid_native_resources',
    message: 'Android notification resources are incomplete.',
  );
}
