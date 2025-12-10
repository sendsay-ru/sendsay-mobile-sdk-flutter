import 'order_item.dart';

class TrackSSECData {
  // Продукт
  final String? productId;
  final String? productName;
  final List<String>? picture;
  final String? url;
  final int? available;
  final List<String>? categoryPaths;
  final int? categoryId;
  final String? category;
  final String? description;
  final String? vendor;
  final String? model;
  final String? type;
  final double? price;
  final double? oldPrice;

  // Продуктовое обновление
  final int? updatePerItem;
  final int? update;

  // Транзакция
  final String? transactionId;
  final String? transactionDt;
  final int? transactionStatus;
  final double? transactionDiscount;
  final double? transactionSum;

  // Доставка и оплата
  final String? deliveryDt;
  final double? deliveryPrice;
  final String? paymentDt;

  // items (для заказов/корзины)
  final List<OrderItem>? items;

  // Подписка на изменения / избранное
  final List<OrderItem>? subscriptionAdd;
  final List<int>? subscriptionDelete;
  final int? subscriptionClear;

  const TrackSSECData({
    this.productId,
    this.productName,
    this.picture,
    this.url,
    this.available,
    this.categoryPaths,
    this.categoryId,
    this.category,
    this.description,
    this.vendor,
    this.model,
    this.type,
    this.price,
    this.oldPrice,
    this.updatePerItem,
    this.update,
    this.transactionId,
    this.transactionDt,
    this.transactionStatus,
    this.transactionDiscount,
    this.transactionSum,
    this.deliveryDt,
    this.deliveryPrice,
    this.paymentDt,
    this.items,
    this.subscriptionAdd,
    this.subscriptionDelete,
    this.subscriptionClear,
  });

  /// Плоская мапа для properties["ssec"].
  Map<String, dynamic> toSsecMap() {
    final out = <String, dynamic>{};

    void put(String key, dynamic value) {
      if (value != null) out[key] = value;
    }

    // product
    put('productId', productId);
    put('productName', productName);
    put('picture', picture);
    put('url', url);
    put('available', available);
    put('categoryPaths', categoryPaths);
    put('categoryId', categoryId);
    put('category', category);
    put('description', description);
    put('vendor', vendor);
    put('model', model);
    put('type', type);
    put('price', price);
    put('oldPrice', oldPrice);

    // update
    put('updatePerItem', updatePerItem);
    put('update', update);

    // transaction
    put('transactionId', transactionId);
    put('transactionDt', transactionDt);
    put('transactionStatus', transactionStatus);
    put('transactionDiscount', transactionDiscount);
    put('transactionSum', transactionSum);

    // delivery / payment
    put('deliveryDt', deliveryDt);
    put('deliveryPrice', deliveryPrice);
    put('paymentDt', paymentDt);

    // items (ORDER / BASKET)
    if (items != null) {
      out['items'] = items!.map((e) => e.toJson()).toList();
    }

    // subscription / favorites
    if (subscriptionAdd != null) {
      out['add'] = subscriptionAdd!.map((e) => e.toJson()).toList();
    }
    put('delete', subscriptionDelete);
    put('clear', subscriptionClear);

    return out;
  }

  Map<String, dynamic> toProperties() => {'ssec': toSsecMap()};

  TrackSSECData copyWith({
    String? productId,
    String? productName,
    List<String>? picture,
    String? url,
    int? available,
    List<String>? categoryPaths,
    int? categoryId,
    String? category,
    String? description,
    String? vendor,
    String? model,
    String? type,
    double? price,
    double? oldPrice,
    int? updatePerItem,
    int? update,
    String? transactionId,
    String? transactionDt,
    int? transactionStatus,
    double? transactionDiscount,
    double? transactionSum,
    String? deliveryDt,
    double? deliveryPrice,
    String? paymentDt,
    List<OrderItem>? items,
    List<OrderItem>? subscriptionAdd,
    List<int>? subscriptionDelete,
    int? subscriptionClear,
  }) {
    return TrackSSECData(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      picture: picture ?? this.picture,
      url: url ?? this.url,
      available: available ?? this.available,
      categoryPaths: categoryPaths ?? this.categoryPaths,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      description: description ?? this.description,
      vendor: vendor ?? this.vendor,
      model: model ?? this.model,
      type: type ?? this.type,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      updatePerItem: updatePerItem ?? this.updatePerItem,
      update: update ?? this.update,
      transactionId: transactionId ?? this.transactionId,
      transactionDt: transactionDt ?? this.transactionDt,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      transactionDiscount: transactionDiscount ?? this.transactionDiscount,
      transactionSum: transactionSum ?? this.transactionSum,
      deliveryDt: deliveryDt ?? this.deliveryDt,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      paymentDt: paymentDt ?? this.paymentDt,
      items: items ?? this.items,
      subscriptionAdd: subscriptionAdd ?? this.subscriptionAdd,
      subscriptionDelete: subscriptionDelete ?? this.subscriptionDelete,
      subscriptionClear: subscriptionClear ?? this.subscriptionClear,
    );
  }
}

enum SSECTransactionStatus {
  registered(1, 'Заказ Оформлен (создан,принят)'),
  paid(2, 'Заказ Оплачен'),
  accepted(3, 'Заказ Принят в работу (сборка, комплектация)'),
  delivery(4, 'Доставка'),
  deliveryTracking(5, 'Доставка: присвоен трек-номер'),
  deliveryHandedOver(6, 'Доставка: передан в доставку'),
  deliveryShipped(7, 'Доставка: отправлен'),
  deliveryCourierOrPoint(
      8, 'Доставка: поступил в пункт-выдачи / передан курьеру'),
  deliveryReceived(9, 'Доставка: получен'),
  canceled(10, 'Заказ Отменен: отмена заказа'),
  canceledReturn(11, 'Заказ Отменен: возврат заказа'),
  changedUpdateOrder(12, 'Заказ Изменен: обновление заказа');

  final int code;
  final String? desc;

  const SSECTransactionStatus(this.code, this.desc);

  static SSECTransactionStatus? fromCode(int? code) {
    if (code == null) return null;
    for (final status in SSECTransactionStatus.values) {
      if (status.code == code) return status;
    }
    return null;
  }
}
