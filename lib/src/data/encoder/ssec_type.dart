import '../model/ssec_type.dart';

abstract class SSECTypeEncoder {
  static String encode(TrackingSSECType type) => type.value;

  static TrackingSSECType decode(String value) {
    final result = TrackingSSECType.values.firstWhere( (e) => e.value == value);
    return result;
  }
}
