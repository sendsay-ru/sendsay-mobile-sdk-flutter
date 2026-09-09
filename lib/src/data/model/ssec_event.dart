import 'package:meta/meta.dart';
import 'package:sendsay/sendsay.dart';

@immutable
class SSECEvent {
  final TrackingSSECType type;
  final TrackSSECData data;

  const SSECEvent({
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toSsecMap() {
    return {
      'type': type.value,
      'data': data.toSsecMap(),
    };
  }

  @override
  String toString() {
    return 'SSECEvent{'
        'type: ${type.value}, '
        'data: ${data.toSsecMap()}'
        '}';
  }
}
