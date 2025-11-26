class OrderItem {
  /// id — обязательный
  final String id;

  /// qnt (кол-во)
  final int? qnt;

  /// price (цена)
  final double? price;

  final String? name;
  final String? description;
  final String? uniq;
  final int? available;
  final double? oldPrice;
  final List<String>? picture;
  final String? url;
  final String? model;
  final String? vendor;
  final int? categoryId;
  final String? category;

  /// cp1..cp20: ключи вида "cp1", "cp2", ..., "cp20".
  final Map<String, dynamic>? cp;

  const OrderItem({
    required this.id,
    this.qnt,
    this.price,
    this.name,
    this.description,
    this.uniq,
    this.available,
    this.oldPrice,
    this.picture,
    this.url,
    this.model,
    this.vendor,
    this.categoryId,
    this.category,
    this.cp,
  });

  /// То, что реально пойдёт в JSON / SSEC payload.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
    };

    void put(String key, dynamic value) {
      if (value != null) map[key] = value;
    }

    put('qnt', qnt);
    put('price', price);
    put('name', name);
    put('description', description);
    put('uniq', uniq);
    put('available', available);
    put('old_price', oldPrice);
    put('picture', picture);
    put('url', url);
    put('model', model);
    put('vendor', vendor);
    put('category_id', categoryId);
    put('category', category);

    // cp1..cp20
    if (cp != null) {
      cp!.forEach((key, value) {
        if (value == null) return;
        // только ключи формата cp\d+
        final isCp = RegExp(r'^cp\d+$').hasMatch(key);
        if (isCp) {
          map[key] = value;
        }
      });
    }

    return map;
  }

  /// Для совместимости с тем, что у нас в трекере
  Map<String, dynamic> toSsecMap() => toJson();

  /// Обратная операция к кастомному десериалайзеру.
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Собираем все cp1..cp20 обратно в map
    final cp = <String, dynamic>{};
    json.forEach((key, value) {
      if (RegExp(r'^cp\d+$').hasMatch(key)) {
        cp[key] = value;
      }
    });

    List<String>? parsePicture(dynamic raw) {
      if (raw == null) return null;
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return null;
    }

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return OrderItem(
      id: json['id']?.toString() ?? '',
      qnt: asInt(json['qnt']),
      price: asDouble(json['price']),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      uniq: json['uniq']?.toString(),
      available: asInt(json['available']),
      oldPrice: asDouble(json['old_price']),
      picture: parsePicture(json['picture']),
      url: json['url']?.toString(),
      model: json['model']?.toString(),
      vendor: json['vendor']?.toString(),
      categoryId: asInt(json['category_id']),
      category: json['category']?.toString(),
      cp: cp.isEmpty ? null : cp,
    );
  }

  OrderItem copyWith({
    String? id,
    int? qnt,
    double? price,
    String? name,
    String? description,
    String? uniq,
    int? available,
    double? oldPrice,
    List<String>? picture,
    String? url,
    String? model,
    String? vendor,
    int? categoryId,
    String? category,
    Map<String, dynamic>? cp,
  }) {
    return OrderItem(
      id: id ?? this.id,
      qnt: qnt ?? this.qnt,
      price: price ?? this.price,
      name: name ?? this.name,
      description: description ?? this.description,
      uniq: uniq ?? this.uniq,
      available: available ?? this.available,
      oldPrice: oldPrice ?? this.oldPrice,
      picture: picture ?? this.picture,
      url: url ?? this.url,
      model: model ?? this.model,
      vendor: vendor ?? this.vendor,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      cp: cp ?? this.cp,
    );
  }
}
