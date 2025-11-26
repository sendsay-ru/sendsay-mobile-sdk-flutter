import '../model/ssec_type.dart';

abstract class SSECTypeEncoder {
  static int encode(TrackingSSECType type) => type.id;

  static TrackingSSECType decode(int value) {
    val result = TrackingSSECType.values.where( (e) => e.id == value );
    if (result != null) return result;
    else throw UnsupportedError('`$value` is not an TrackingSSECType!');
    // switch (value) {
    //   case TrackingSSECType.basketClear.value:
    //     return TrackingSSECType.basketClear;
    //   case TrackingSSECType.basketAdd.value:
    //     return TrackingSSECType.basketAdd;
    //   case TrackingSSECType.order.value:
    //     return TrackingSSECType.order;
    //   case TrackingSSECType.viewProduct.value:
    //     return TrackingSSECType.viewProduct;
    //   default:
    //     throw UnsupportedError('`$value` is not an TrackingSSECType!');
    // }
  }
}
