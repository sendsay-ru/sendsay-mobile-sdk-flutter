import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendsay/sendsay.dart';

class SsecBlock extends StatelessWidget {
  final Function(SSECEvent event) callback;

  const SsecBlock({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: const Text('SSEC Track'),
        subtitle: Wrap(
          alignment: WrapAlignment.start,
          spacing: 16,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => callback(
                SSECEvent(
                  type: TrackingSSECType.viewProduct,
                  data: TrackSSEC.viewProduct()
                      .product(
                        id: "101626",
                        name: "Кеды",
                        picture: [
                          "https://m.media-amazon.com/images/I/71UiJ6CG9ZL._AC_UL320_.jpg"
                        ],
                        url: "https://sendsay.ru/catalog/kedy/kedy_290/",
                        categoryId: 1117,
                        model: "506-066 139249",
                        price: 4490.0,
                      )
                      .buildData(),
                ),
              ),
              child: const Text('PRODUCT VIEW'),
            ),
            ElevatedButton(
              onPressed: () {
                final randomTransactionId =
                    Random.secure().nextInt(99999).abs().toString();
                final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                final String currentDateTime = formatter.format(DateTime.now());

                callback(
                  SSECEvent(
                    type: TrackingSSECType.order,
                    data: TrackSSEC.order()
                        .update(isUpdatePerItem: false)
                        .transaction(
                            id: randomTransactionId,
                            dt: currentDateTime,
                            sum: 1490.0,
                            status: 1)
                        .items([
                      const OrderItem(
                        id: "101695",
                        qnt: 1,
                        price: 1490.0,
                        name: "Сумка",
                        picture: [
                          "https://m.media-amazon.com/images/I/81h0fWxyp9S._AC_UL320_.jpg"
                        ],
                        url: "https://sendsay.ru/catalog/sumki_1/sumka_468/",
                        model: "1110-001 139276",
                        categoryId: 1154,
                        cp: {"cp1": "promo-2025"},
                      )
                    ]).buildData(),
                  ),
                );
              },
              child: const Text('ORDER'),
            ),
            ElevatedButton(
              onPressed: () {
                final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                final String currentDateTime = formatter.format(DateTime.now());

                callback(
                  SSECEvent(
                      type: TrackingSSECType.basketClear,
                      data: TrackSSEC.basketClear()
                          .dateTime(currentDateTime)
                          .items([const OrderItem(id: "-1")]).buildData()),
                );
              },
              child: const Text('CLEAR BASKET'),
            ),
            ElevatedButton(
              onPressed: () {
                final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                final String currentDateTime = formatter.format(DateTime.now());

                callback(
                  SSECEvent(
                    type: TrackingSSECType.basketAdd,
                    data: TrackSSEC.basketAdd()
                        .transaction(
                            id: "2968",
                            dt: currentDateTime,
                            sum: 2590.0,
                            status: 1)
                        .items([
                      const OrderItem(
                        id: "101115",
                        qnt: 1,
                        price: 2590.0,
                        name: "Рюкзак",
                        picture: [
                          "https://m.media-amazon.com/images/I/91fkUMA5K1L._AC_UL320_.jpg"
                        ],
                        url: "https://sendsay.ru/catalog/ryukzaki/ryukzak_745/",
                        model: "210-045 138761",
                        categoryId: 1153,
                        // cp: {"cp1": "promo-2025"},
                      ),
                    ]).buildData(),
                  ),
                );
              },
              child: const Text('ADD BASKET'),
            ),
          ],
        ));
  }
}
