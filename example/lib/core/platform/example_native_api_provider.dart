import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'example_native_api.dart';
import 'method_channel_example_native_api.dart';

/// Shared native API; override with a fake for application and widget tests.
final exampleNativeApiProvider = Provider<ExampleNativeApi>((ref) {
  return const MethodChannelExampleNativeApi();
});
