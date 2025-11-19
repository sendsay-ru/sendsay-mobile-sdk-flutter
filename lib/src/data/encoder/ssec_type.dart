import '../model/ssec_type.dart';

abstract class SSECTypeEncoder {
  static String encode(TrackingSSECType type) {
    switch (type) {
      case TrackingSSECType.basketClear:
        return TrackingSSECType.basketClear.value;
      case TrackingSSECType.basketAdd:
        return TrackingSSECType.basketAdd.value;
      case TrackingSSECType.order:
        return TrackingSSECType.order.value;
      case TrackingSSECType.viewProduct:
        return TrackingSSECType.viewProduct.value;
    }
  }

  static EventType decode(String value) {
    switch (value) {
      case TrackingSSECType.basketClear.value:
        return TrackingSSECType.basketClear;
      case TrackingSSECType.basketAdd.value:
        return TrackingSSECType.basketAdd;
      case TrackingSSECType.order.value:
        return TrackingSSECType.order;
      case TrackingSSECType.viewProduct.value:
        return TrackingSSECType.viewProduct;
      default:
        throw UnsupportedError('`$value` is not an EventType!');
    }
  }
}
