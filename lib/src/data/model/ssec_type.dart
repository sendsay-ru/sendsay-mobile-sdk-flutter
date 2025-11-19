enum TrackingSSECType {
  viewProduct('ssec_product_view', 0),
  order('ssec_order', 1),
  viewCategory('ssec_category_view', 2),
  basketAdd('ssec_basket', 3),
  basketClear('ssec_basket_clear', 4),
  searchProduct('ssec_product_search', 5),
  subscribeProductPrice('ssec_product_price', 6),
  subscribeProductIsa('ssec_subscribe_product_isa', 7),
  favorite('ssec_product_favorite', 8),
  preorder('ssec_product_preorder', 12),
  productIsa('ssec_product_isa', 13),
  productPriceChanged('ssec_product_price_changed', 15),
  registration('ssec_registration', 28),
  authorization('ssec_authorization', 29);

  final String value;
  final int id;

  const TrackingSSECType(this.value, this.id);

  // static TrackingSSECType? find({String? value, int? id}) {
  //   for (final t in TrackingSSECType.values) {
  //     final matchesValue =
  //         value != null && t.value.toLowerCase() == value.toLowerCase();
  //     final matchesId = id != null && t.id == id;
  //     if (matchesValue || matchesId) {
  //       return t;
  //     }
  //   }
  //   return null;
  // }
}
