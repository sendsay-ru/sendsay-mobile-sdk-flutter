---
title: iOS Push-уведомления
excerpt: Включение push-уведомлений в вашем приложении с помощью iOS SDK
slug: flutter-sdk-push-ios
categorySlug: integrations
parentDocSlug: flutter-sdk-push-notifications
---

SDK Flutter использует [нативный SDK iOs](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios) для обработки push-уведомлений в iOs. В этом руководстве приведены сокращенные инструкции для iOs в контексте Flutter SDK, а подробная информация приведена в [документации по push-уведомлениям для iOs SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/docs/push-notifications.md).

> 📘
>
> Чтобы узнать, как создавать push-уведомления в веб-приложении CDP Sendsay, обратитесь к [Мобильные push-уведомления](https://docs.sendsay.ru/other-channels/mobile-push/how-to-connect-mobile-push#%D0%BF%D0%B0%D1%80%D0%B0%D0%BC%D0%B5%D1%82%D1%80%D1%8B-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D1%8F).

> ❗️ Устаревание автоматических push-уведомлений
>
> Предыдущие версии SDK использовали method swizzling для автоматической регистрации push-уведомлений. Иногда это вызывало проблемы и поэтому больше не поддерживается. Обратитесь к [Реализация методов делегата приложения](#шаг-2-реализация-методов-делегата-приложения) ниже для списка методов делегата, которые ваше приложение должно реализовать для правильной обработки push-уведомлений.

## Требования

Чтобы иметь возможность отправлять push-уведомления из CDP Sendsay, вы должны:

- Получить ключ подписи токена аутентификации Apple Push Notification service (APNs)
- Добавить и настроить интеграцию Apple Push Notification Service в веб-приложении CDP Sendsay

> 📘
>
> Если вы еще не настроили это, следуйте инструкциям в [Настройка Apple Push Notification Service](https://docs.sendsay.ru/other-channels/mobile-push/how-to-connect-mobile-push/#%D0%BF%D0%B0%D1%80%D0%B0%D0%BC%D0%B5%D1%82%D1%80%D1%8B-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D1%8F).

## Интеграция

Этот раздел описывает шаги для добавления минимальной функциональности push-уведомлений (получение уведомлений с предупреждениями) в ваше приложение.

### Шаг 1: Включение возможностей push

Выберите цель вашего приложения в Xcode, и на вкладке `Signing & Capabilities` добавьте следующие возможности:

- `Push Notifications`
  Требуется для push-уведомлений с предупреждениями.
- `Background Modes` (выберите `Remote notifications`)
  Требуется для тихих push-уведомлений.
- `App Groups` (создайте новую группу приложений для вашего приложения)
  Требуется для расширений приложения, которые обрабатывают доставку push-уведомлений и богатый контент.

> ❗️
>
> Учетная запись разработчика Apple с платным членством должна добавить возможность `Push Notifications`.


### Шаг 2: Реализация методов делегата приложения

Чтобы ваше приложение могло реагировать на события, связанные с push-уведомлениями, его `AppDelegate` должен реализовывать несколько методов (подробности см. в [документации по нативному SDK iOS](push-ios.md#шаг-3-настройте-группу-приложений)).

Класс [`SendsayFlutterAppDelegate`](https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter/blob/main/ios/Classes/SendsayFlutterAppDelegate.swift) в Flutter SDK предоставляет стандартные реализации этих методов. Мы рекомендуем расширить `SendsayFlutterAppDelegate` в вашем `AppDelegate`.

Откройте `AppDelegate.swift` и замените его содержимое следующим:

```swift
import Foundation
import Flutter
import sendsay

@UIApplicationMain
@objc class AppDelegate: SendsayFlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

Если по какой-то причине вы не хотите или не можете расширить `SendsayFlutterAppDelegate`, вы можете использовать его в качестве справочного материала для самостоятельной реализации необходимых методов делегата.

### Шаг 3: Настройте группу приложений

При [инициализации SDK](../doc/setup.md#инициализируйте-sdk) необходимо установить свойство `appGroup` в значение группы приложений, созданной в [шаге 1](#шаг-1-включение-возможностей-push):

```dart
import 'package:sendsay/sendsay.dart';

final _plugin = SendsayPlugin();
_plugin.configure(SendsayConfiguration(
  // ...
  ios: IOSSendsayConfiguration(
    appGroup: 'your app group',
  ),
));
```

### Шаг 4: Запрос разрешения на отправку уведомлений

Вашему приложению требуется явное разрешение от пользователя на отправку «оповещающих» уведомлений, которые будут видны пользователю.

Вы можете запросить разрешение у пользователей, вызвав `SendsayPlugin().requestPushAuthorization()`:

```dart
_plugin.requestPushAuthorization()
.then((accepted) => print("User has ${accepted ? 'accepted': 'rejected'} push notifications."))
.catchError((error) => print('Error: $error'));
```

> 👍
>
> Статус авторизации push-уведомлений отслеживается как свойство клиента `apple_push_notification_authorized`.

### Контрольный список:

- [ ] CDP Sendsay теперь должен быть способен отправлять push-уведомления на устройства iOS. Инструкции см. в руководстве [Создание нового уведомления](https://docs.sendsay.ru/other-channels/mobile-push/how-to-create-mobile-push-campaign).
- [ ] На данный момент ваше приложение не отображает изображения или действия в push-уведомлениях. Следуйте инструкциям по реализации [богатых push-уведомлений](#rich-push-notifications), если вы хотите поддерживать эту функцию.

## Настройка

В этом разделе описаны настройки, которые можно реализовать после интеграции минимальной функциональности push-уведомлений.

### Расширенные push-уведомления (в разработке)

Расширенные push-уведомления могут содержать изображения и кнопки. Чтобы включить эту функцию, необходимо добавить два расширения приложения: **Notification Service Extension** и **Notification Content Extension**.

Для каждого расширения следуйте инструкциям в разделе [Расширения уведомлений](https://documentation.bloomreach.com/engagement/docs/ios-sdk-notification-extensions) в документации по нативному SDK для iOS, чтобы правильно настроить его для использования службы уведомлений Sendsay, включенной в SDK для iOS.

Вызов метода `SendsayNotificationContentService.didReceive()` улучшит тело уведомления с помощью изображения и действий, доставленных в рамках полезной нагрузки `UNNotification`. Действия уведомлений, отображаемые `SendsayNotificationContentService`, регистрируются с конфигурациями для автоматического открытия вашего приложения с необходимой информацией и обработки кликов кампании.

#### Контрольный список:
- [ ] Убедитесь, что push-уведомления с изображениями и кнопками, отправленные из CDP Sendsay, правильно отображаются на вашем устройстве. Отслеживание доставки push-уведомлений должно работать.
- [ ] Если вы не видите кнопки в развернутом push-уведомлении, расширение контента **не** работает. Дважды проверьте `UNNotificationExtensionCategory` в `Info.plist` — обратите внимание на размещение внутри `NSExtensionAttributes`. Убедитесь, что `iOS Deployment Target` одинаков для расширений и основного приложения.

### Получение токена push-уведомления вручную

Иногда вашему приложению может потребоваться получить текущий токен push-уведомления во время работы. Это можно сделать с помощью метода `Sendsay.shared.trackPushToken`.

Часто это делается при вызове метода `SendsayPlugin().anonymize()`. Вызов `anonymize` удаляет токен push-уведомлений из локального хранилища. Поэтому его необходимо обновить сразу после `anonymize` или до/после `identifyCustomer`, в зависимости от того, как вы используете push-уведомления.

``` swift
Messaging.messaging().token { token, error in
  if let token = token {
    SwiftSendsayPlugin.handlePushNotificationToken(deviceToken: token)
    resolve(nil)
  } else {
    reject(error)
  }
}
```

### Показать уведомления на переднем плане

Система вызывает следующий метод, если приложение находится на переднем плане во время поступления push-уведомления. По умолчанию push-уведомление отображается. Вы можете переопределить этот метод, если хотите изменить поведение по умолчанию.

```swift
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // show notification even if the app is in the foreground
        if #available(iOS 14, *) {
            completionHandler([.banner])
        } else {
            completionHandler([.alert])
        }
    }
```
