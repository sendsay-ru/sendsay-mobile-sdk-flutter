import 'order_item.dart';
import 'package:sendsay/sendsay.dart';


abstract class TrackSSECBuilder {
  TrackSSECData buildData();
  Map<String, dynamic> buildProperties();
}

/// VIEW_PRODUCT
class ViewProductBuilder implements TrackSSECBuilder {
  final TrackSSECDataCore _core;

  ViewProductBuilder([TrackSSECDataCore? core])
      : _core = core ?? TrackSSECDataCore(TrackingSSECType.viewProduct);

  /// Обязательное поле — id; остальные опциональны
  ViewProductBuilder product({
    required String id,
    String? name,
    String? dateTime,
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
  }) {
    _core.setProduct(
      id: id,
      name: name,
      dateTime: dateTime,
      picture: picture,
      url: url,
      available: available,
      categoryPaths: categoryPaths,
      categoryId: categoryId,
      category: category,
      description: description,
      vendor: vendor,
      model: model,
      type: type,
      price: price,
      oldPrice: oldPrice,
    );
    return this;
  }

  ViewProductBuilder update({bool? isUpdate, bool? isUpdatePerItem}) {
    _core.setUpdate(isUpdate: isUpdate, isUpdatePerItem: isUpdatePerItem);
    return this;
  }

  @override
  TrackSSECData buildData() => _core.build();

  @override
  Map<String, dynamic> buildProperties() => _core.build().toProperties();
}

/// ORDER
class OrderBuilder implements TrackSSECBuilder {
  final TrackSSECDataCore _core;

  OrderBuilder([TrackSSECDataCore? core])
      : _core = core ?? TrackSSECDataCore(TrackingSSECType.order);

  /// discount – не обязательно
  OrderBuilder transaction({
    required String id,
    required String dt,
    required double sum,
    required int status,
    double? discount,
  }) {
    _core.setTransaction(
      id: id,
      dt: dt,
      sum: sum,
      discount: discount,
      status: status,
    );
    return this;
  }

  OrderBuilder update({bool? isUpdate, bool? isUpdatePerItem}) {
    _core.setUpdate(isUpdate: isUpdate, isUpdatePerItem: isUpdatePerItem);
    return this;
  }

  OrderBuilder delivery(String dt, {double? price}) {
    _core.setDelivery(dt, price);
    return this;
  }

  OrderBuilder payment(String dt) {
    _core.setPayment(dt);
    return this;
  }

  /// Товары — без nullable внутри
  OrderBuilder items(List<OrderItem> items) {
    _core.setItems(items);
    return this;
  }

  /// Иногда магазины передают product-поля и для ORDER
  OrderBuilder productOptional({
    String? id,
    String? name,
    double? price,
  }) {
    _core.setProduct(id: id, name: name, price: price);
    return this;
  }

  @override
  TrackSSECData buildData() => _core.build();

  @override
  Map<String, dynamic> buildProperties() => _core.build().toProperties();
}

/// BASKET_ADD
class BasketAddBuilder implements TrackSSECBuilder {
  final TrackSSECDataCore _core;

  BasketAddBuilder([TrackSSECDataCore? core])
      : _core = core ?? TrackSSECDataCore(TrackingSSECType.basketAdd);

  BasketAddBuilder transaction({
    required String id,
    required String dt,
    double? sum,
    int? status,
    double? discount,
  }) {
    _core.setTransaction(
      id: id,
      dt: dt,
      sum: sum,
      status: status,
      discount: discount,
    );
    return this;
  }

  BasketAddBuilder items(List<OrderItem> items) {
    _core.setItems(items);
    return this;
  }

  @override
  TrackSSECData buildData() => _core.build();

  @override
  Map<String, dynamic> buildProperties() => _core.build().toProperties();
}

/// BASKET_CLEAR
class BasketClearBuilder implements TrackSSECBuilder {
  final TrackSSECDataCore _core;

  BasketClearBuilder([TrackSSECDataCore? core])
      : _core = core ?? TrackSSECDataCore(TrackingSSECType.basketClear);

  BasketClearBuilder items(List<OrderItem> items) {
    _core.setItems(items);
    return this;
  }

  BasketClearBuilder dateTime(String dt) {
    _core.setProduct(dateTime: dt);
    return this;
  }

  @override
  TrackSSECData buildData() => _core.build();

  @override
  Map<String, dynamic> buildProperties() => _core.build().toProperties();
}

/// VIEW_CATEGORY
class ViewCategoryBuilder implements TrackSSECBuilder {
  final TrackSSECDataCore _core;

  ViewCategoryBuilder([TrackSSECDataCore? core])
      : _core = core ?? TrackSSECDataCore(TrackingSSECType.viewCategory);

  ViewCategoryBuilder searchByCategoryDescription(String? category) {
    _core.searchCategory(category: category);
    return this;
  }

  ViewCategoryBuilder searchByCategoryId(int? categoryId) {
    _core.searchCategory(categoryId: categoryId);
    return this;
  }

  @override
  TrackSSECData buildData() => _core.build();

  @override
  Map<String, dynamic> buildProperties() => _core.build().toProperties();
}

/// SEARCH_PRODUCT
class SearchProductBuilder implements TrackSSECBuilder {
  final TrackSSECDataCore _core;

  SearchProductBuilder([TrackSSECDataCore? core])
      : _core = core ?? TrackSSECDataCore(TrackingSSECType.searchProduct);

  SearchProductBuilder search(String description) {
    _core.searchDescription(description);
    return this;
  }

  @override
  TrackSSECData buildData() => _core.build();

  @override
  Map<String, dynamic> buildProperties() => _core.build().toProperties();
}

/// SUBSCRIBE_PRODUCT_PRICE / SUBSCRIBE_PRODUCT_ISA / FAVORITE / PREORDER / PRODUCT_ISA / PRODUCT_PRICE_CHANGED
class SubscribeProductBuilder implements TrackSSECBuilder {
  final TrackingSSECType type;
  final TrackSSECDataCore _core;

  SubscribeProductBuilder(
      this.type, [
        TrackSSECDataCore? core,
      ]) : _core = core ?? TrackSSECDataCore(type);

  SubscribeProductBuilder add(List<OrderItem> items) {
    _core.setSubscriptionOrFavoritesAdd(items);
    return this;
  }

  SubscribeProductBuilder delete(List<int> itemsId) {
    _core.setSubscriptionOrFavoritesDelete(itemsId);
    return this;
  }

  SubscribeProductBuilder clear(bool eraseAll) {
    _core.setSubscriptionOrFavoritesClear(eraseAll);
    return this;
  }

  @override
  TrackSSECData buildData() => _core.build();

  @override
  Map<String, dynamic> buildProperties() => _core.build().toProperties();
}

/// Фабрика удобного доступа — аналог object TrackSSEC
class TrackSSEC {
  const TrackSSEC._();

  static ViewProductBuilder viewProduct() => ViewProductBuilder();
  static OrderBuilder order() => OrderBuilder();
  static BasketAddBuilder basketAdd() => BasketAddBuilder();
  static BasketClearBuilder basketClear() => BasketClearBuilder();
  static ViewCategoryBuilder viewCategory() => ViewCategoryBuilder();
  static SearchProductBuilder search() => SearchProductBuilder();
  static SubscribeProductBuilder subscribePrice() =>
      SubscribeProductBuilder(TrackingSSECType.subscribeProductPrice);
  static SubscribeProductBuilder subscribeISA() =>
      SubscribeProductBuilder(TrackingSSECType.subscribeProductIsa);
  static SubscribeProductBuilder favorite() =>
      SubscribeProductBuilder(TrackingSSECType.favorite);
  static SubscribeProductBuilder preorder() =>
      SubscribeProductBuilder(TrackingSSECType.preorder);
  static SubscribeProductBuilder productISA() =>
      SubscribeProductBuilder(TrackingSSECType.productIsa);
  static SubscribeProductBuilder productPriceChanged() =>
      SubscribeProductBuilder(TrackingSSECType.productPriceChanged);

  static TrackSSECBuilder builder(TrackingSSECType type) {
    switch (type) {
      case TrackingSSECType.viewProduct:
        return viewProduct();
      case TrackingSSECType.order:
        return order();
      case TrackingSSECType.basketAdd:
        return basketAdd();
      case TrackingSSECType.basketClear:
        return basketClear();
      case TrackingSSECType.viewCategory:
        return viewCategory();
      case TrackingSSECType.searchProduct:
        return search();
      case TrackingSSECType.subscribeProductPrice:
        return subscribePrice();
      case TrackingSSECType.subscribeProductIsa:
        return subscribeISA();
      case TrackingSSECType.favorite:
        return favorite();
      case TrackingSSECType.preorder:
        return preorder();
      case TrackingSSECType.productIsa:
        return productISA();
      case TrackingSSECType.productPriceChanged:
        return productPriceChanged();
      case TrackingSSECType.registration:
      case TrackingSSECType.authorization:
      // Для этих типов билдеры не реализованы — можно добавить при необходимости
        return viewProduct();
    }
  }
}

class TrackSSECDataCore {
  final TrackingSSECType type;

  String? _productId;
  String? _productName;
  String? _productDateTime;
  List<String>? _productPicture;
  String? _productUrl;
  int? _productAvailable;
  List<String>? _productCategoryPaths;
  int? _productCategoryId;
  String? _productCategory;
  String? _productDescription;
  String? _productVendor;
  String? _productModel;
  String? _productType;
  double? _productPrice;
  double? _productOldPrice;

  int? _updatePerItem;
  int? _update;

  String? _transactionId;
  String? _transactionDt;
  double? _transactionSum;
  double? _transactionDiscount;
  int? _transactionStatus;

  String? _deliveryDt;
  double? _deliveryPrice;
  String? _paymentDt;

  List<OrderItem>? _items;

  List<OrderItem>? _subscriptionAdd;
  List<int>? _subscriptionDelete;
  int? _subscriptionClear;

  TrackSSECDataCore(this.type);

  // setProduct / setTransaction / setDelivery / setPayment / setUpdate
  // остаются такими же, как я тебе уже кидал — их можно не трогать.

  void setProduct({
    String? id,
    String? name,
    String? dateTime,
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
  }) {
    _productId = id;
    _productName = name;
    _productDateTime = dateTime;
    _productPicture = picture;
    _productUrl = url;
    _productAvailable = available;
    _productCategoryPaths = categoryPaths;
    _productCategoryId = categoryId;
    _productCategory = category;
    _productDescription = description;
    _productVendor = vendor;
    _productModel = model;
    _productType = type;
    _productPrice = price;
    _productOldPrice = oldPrice;
  }

  void setTransaction({
    String? id,
    String? dt,
    double? sum,
    double? discount,
    int? status,
  }) {
    _transactionId = id;
    _transactionDt = dt;
    _transactionSum = sum;
    _transactionDiscount = discount;
    _transactionStatus = status;
  }

  void setDelivery(String dt, [double? deliveryPrice]) {
    _deliveryDt = dt;
    _deliveryPrice = deliveryPrice;
  }

  void setPayment(String dt) {
    _paymentDt = dt;
  }

  void setUpdate({bool? isUpdate, bool? isUpdatePerItem}) {
    if (isUpdate != null) _update = isUpdate ? 1 : 0;
    if (isUpdatePerItem != null) {
      _updatePerItem = isUpdatePerItem ? 1 : 0;
    }
  }

  void setItems(List<OrderItem> items) {
    _items = items;
  }

  void setSubscriptionOrFavoritesAdd(List<OrderItem> orderItems) {
    _subscriptionAdd = orderItems;
  }

  void setSubscriptionOrFavoritesDelete(List<int> itemsId) {
    _subscriptionDelete = itemsId;
  }

  void setSubscriptionOrFavoritesClear(bool eraseAll) {
    _subscriptionClear = eraseAll ? 1 : 0;
  }

  void searchCategory({String? category, int? categoryId}) {
    if (category != null) _productCategory = category;
    if (categoryId != null) _productCategoryId = categoryId;
  }

  void searchDescription(String description) {
    _productDescription = description;
  }

  TrackSSECData build() {
    // Валидация слегка упрощённая, но логика та же.
    switch (type) {
      case TrackingSSECType.viewProduct:
        if (_productId == null) {
          throw StateError('product.id is required for VIEW_PRODUCT');
        }
        break;

      case TrackingSSECType.order:
        if (_transactionId == null ||
            _transactionDt == null ||
            _transactionSum == null ||
            _transactionStatus == null) {
          throw StateError(
              'transaction.id, dt, sum, status are required for ORDER');
        }
        if (_update == 1 && (_items == null || _items!.isEmpty)) {
          throw StateError(
              'items must be provided for ORDER when update == 1');
        }
        break;

      case TrackingSSECType.basketAdd:
        if (_transactionId == null || _transactionDt == null) {
          throw StateError(
              'transaction.id and dt are required for BASKET_ADD');
        }
        break;

      case TrackingSSECType.basketClear:
        if (_items == null || _items!.isEmpty) {
          throw StateError('items must be provided for BASKET_CLEAR');
        }
        break;

      case TrackingSSECType.viewCategory:
        final hasCategory =
            _productCategory != null && _productCategory!.isNotEmpty;
        final hasCategoryId = _productCategoryId != null;
        if (!hasCategory && !hasCategoryId) {
          throw StateError(
              'product.category or product.category_id is required for VIEW_CATEGORY');
        }
        break;

      case TrackingSSECType.searchProduct:
        if (_productDescription == null || _productDescription!.isEmpty) {
          throw StateError(
              'product.description is required for SEARCH_PRODUCT');
        }
        break;

      case TrackingSSECType.subscribeProductPrice:
      case TrackingSSECType.subscribeProductIsa:
      case TrackingSSECType.favorite:
      case TrackingSSECType.preorder:
      case TrackingSSECType.productIsa:
        final hasAdd =
            _subscriptionAdd != null && _subscriptionAdd!.isNotEmpty;
        final hasDelete =
            _subscriptionDelete != null && _subscriptionDelete!.isNotEmpty;
        final hasClear = _subscriptionClear == 1;

        final count = [hasAdd, hasDelete, hasClear]
            .where((element) => element)
            .length;

        if (count != 1) {
          throw StateError(
            'Exactly one of add/delete/clear must be set for SUBSCRIBE_... or FAVORITE',
          );
        }
        break;

      case TrackingSSECType.productPriceChanged:
        if (_productId == null ||
            _productPrice == null ||
            _productOldPrice == null) {
          throw StateError(
            'product.id, price and old_price are required for PRODUCT_PRICE_CHANGED',
          );
        }
        break;

      case TrackingSSECType.registration:
      case TrackingSSECType.authorization:
        break;
    }

    final formattedTransactionDt = _transactionDt;
    final formattedDeliveryDt = _deliveryDt;
    final formattedPaymentDt = _paymentDt;

    return TrackSSECData(
      productId: _productId,
      productName: _productName,
      picture: _productPicture,
      url: _productUrl,
      available: _productAvailable,
      categoryPaths: _productCategoryPaths,
      categoryId: _productCategoryId,
      category: _productCategory,
      description: _productDescription,
      vendor: _productVendor,
      model: _productModel,
      type: _productType,
      price: _productPrice,
      oldPrice: _productOldPrice,
      updatePerItem: _updatePerItem,
      update: _update,
      transactionId: _transactionId,
      transactionDt: formattedTransactionDt,
      transactionStatus: _transactionStatus,
      transactionDiscount: _transactionDiscount,
      transactionSum: _transactionSum,
      deliveryDt: formattedDeliveryDt,
      deliveryPrice: _deliveryPrice,
      paymentDt: formattedPaymentDt,
      items: _items,
      subscriptionAdd: _subscriptionAdd,
      subscriptionDelete: _subscriptionDelete,
      subscriptionClear: _subscriptionClear,
    );
  }
}
