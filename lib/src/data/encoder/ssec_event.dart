import '../model/ssec_event.dart';
import '../util/object.dart';

abstract class SSECEventEncoder {
  static SSECEvent decode(Map<String, dynamic> map) {
    return SSECEvent(
      type: map.getRequired('type'),
      data: map.getRequired('data'),
    );
  }

  static Map<String, dynamic> encode(SSECEvent ssec) {
    return {
      'type': ssec.type,
      'data': ssec.data,
    }..removeWhere((key, value) => value == null);
  }
}
