---
title: Push notifications
excerpt: Enable push notifications in your app using the Flutter SDK
slug: flutter-sdk-push-notifications
categorySlug: integrations
parentDocSlug: flutter-sdk
---

CDP Sendsay позволяет отправлять push-уведомления пользователям вашего приложения. Мобильное приложение обрабатывает push-сообщение с помощью SDK и отображает уведомление на устройстве клиента.

Push-уведомления также могут быть тихими, используемыми только для обновления интерфейса приложения или запуска фоновых задач.

> 📘
>
> Чтобы узнать, как создавать push-уведомления в веб-приложении CDP Sendsay, обратитесь к [Мобильные push-уведомления](https://docs.sendsay.ru/other-channels/mobile-push/how-to-create-mobile-push-campaign).

## Требования

SDK Flutter использует базовые native платформы Android и iOS для обработки push-уведомлений.

На следующих страницах описаны шаги для каждой платформы по добавлению минимальной функциональности push-уведомлений (получение оповещений) в ваше приложение.

- [Push-уведомления Android](../doc/push-android.md)
- [Push-уведомления iOS](../doc/push-ios.md)

## Настройка

В этом разделе описаны настройки, которые можно реализовать после интеграции минимальной функциональности push-уведомлений.

### Настройка автоматического отслеживания push-уведомлений

По умолчанию SDK отслеживает push-уведомления автоматически. SDK будет отображать push-уведомления из CDP Sendsay и отслеживать событие «кампания» для каждого доставленного/открытого push-уведомления с соответствующими свойствами.

В [конфигурации SDK](../doc/configuration.md) вы можете установить желаемую частоту, с которой SDK отслеживает токен push-уведомления в CDP Sendsay, с помощью свойства `pushTokenTrackingFrequency` (значение по умолчанию — `TokenFrequency.onTokenChange`).

В Android вы можете отключить автоматическое отслеживание push-уведомлений, установив булево значение свойства `automaticPushNotifications` в `false` в [конфигурации SDK для Android](../doc/configuration.md#параметры-конфигурации-специфичные-для-android).

❗️

В настоящее время Flutter SDK не поддерживает отключение автоматического отслеживания push-уведомлений в iOS.

### Реагирование на взаимодействия с push-уведомлениями

После выполнения шагов по интеграции для каждой платформы ваше приложение должно быть готово к приему push-уведомлений.

Чтобы реагировать на взаимодействие с push-уведомлением, вы можете настроить слушатель для `SendsayPlugin().openedPushStream`:

```dart
import 'package:sendsay/sendsay.dart';

final _plugin = SendsayPlugin();
final subscription = _plugin.openedPushStream.listen((openedPush) {
  switch(openedPush.action) {
    case PushActionType.app:
      // last push directed user to your app with no link

      // log data defined on Sendsay backend
      print('app - ${openedPush.data}'); 
      break;
    case PushActionType.deeplink:
      // last push directed user to your app with deeplink
      print('deeplink - ${openedPush.url}');
      break;
    case PushActionType.web:
      // last push directed user to web, nothing to do here
      print('web');
      break;
  }
});
```

Вызовите `subscription.cancel()`, когда вам больше не нужен слушатель.

Мы рекомендуем зарегистрировать слушателя как можно скорее, чтобы обеспечить правильный поток приложения. Однако SDK будет удерживать последнее push-уведомление и вызовет слушателя, как только он будет зарегистрирован.

> ❗️
>
> Для поддержки deep-links требуются выполнить дополнительные шаги. Обратитесь к документации для соответствующих нативных платформ ([Android](../doc/push-android.md), [iOS](../doc/push-ios.md)). В качестве альтернативы можно использовать действие `Open app` и добавить payload в `Additional data`.


### Реакция на полученние push-уведомления

Вы можете настроить слушатель для полученных push-уведомлений с помощью `SendsayPlugin.receivedPushStream`, что особенно полезно для бесшумных push-уведомлений.

```dart
final subscription = _plugin.receivedPushStream.listen((receivedPush) {
  print(receivedPush);
});
```

Вызовите `subscription.cancel()`, когда вам больше не нужен слушатель.

Мы рекомендуем зарегистрировать слушателя как можно скорее, чтобы обеспечить правильный поток приложения. Однако SDK будет удерживать последнее push-уведомление и вызывать слушателя после его регистрации.

> ❗️
>
> Слушатель вызывается как для обычных, так и для бесшумных push-уведомлений на Android, но **только** для бесшумных push-уведомлений на iOS из-за технических ограничений.

### Ручное отслеживание push-уведомлений

Если вы отключите [автоматическое отслеживание push-уведомлений](#настройка-автоматического-отслеживания-push-уведомлений)(только для Android) или хотите отслеживать push-уведомления от других поставщиков, вы можете вручную отслеживать события, связанные с push-уведомлениями.

> ❗️
>
> В настоящее время Flutter SDK не поддерживает отключение автоматического отслеживания push-уведомлений на iOS.

#### Отслеживание push-токена (FCM)

Используйте метод `trackPushToken` для ручного отслеживания push-токена FCM:

```dart
SendsayPlugin().trackPushToken("382d4221-3441-44b7-a676-3eb5f515157f")
```

Вызов этого метода приведет к немедленному отслеживанию токена push, независимо от [конфигурации SDK](../doc/configuration.md) для `tokenTrackFrequency`.

#### Отслеживание доставленных push-уведомлений

Используйте метод `trackDeliveredPush` для ручного отслеживания доставленных push-уведомлений:

```dart
final Map<String, dynamic> payload = {
  "platform": "android",
  "subject": "subject",
  "type": "push",
  "url_params": {
    "utm_campaign": "Campaign name",
    "utm_medium": "mobile_push_notification",
    "utm_content": "en",
    ...
  },
  ...
};
SendsayPlugin().trackDeliveredPush(payload)
```

> ❗️
>
> На поведение `trackDeliveredPush` может влиять функция согласия на отслеживание, которая, когда включена, требует явного согласия на отслеживание. Подробнее читайте в [документации по согласию на отслеживание](../doc/tracking-consent.md).

#### Отслеживание нажатых push-уведомлений

Используйте метод `trackClickedPush` для ручного отслеживания нажатых push-уведомлений:

```dart
final Map<String, dynamic> payload = {
  "platform": "android",
  "subject": "subject",
  "type": "push",
  "url_params": {
    "utm_campaign": "Campaign name",
    "utm_medium": "mobile_push_notification",
    "utm_content": "en",
    ...
  },
  ...
};
SendsayPlugin().trackClickedPush(payload)
```

> На поведение `trackClickedPush` может влиять функция согласия на отслеживание, которая, когда включена, требует явного согласия на отслеживание. Подробнее читайте в [документации по согласию на отслеживание](tracking-consent.md).

### Пользовательская обработка данных push-уведомлений

Если предоставленные native методы `SendsayModule.Companion.handleRemoteMessage` (Android) и `SendsayNotificationService().process` (iOS)  не соответствуют требованиям вашего приложения, или вы решили отключить автоматические push-уведомления, вам необходимо самостоятельно обрабатывать push-уведомления и их полезную нагрузку.

Полезные нагрузки уведомлений генерируются на основе (возможно сложных) сценариев в платформе CDP Sendsay и содержат все данные для платформ Android, iOS и веб. Поэтому сама полезная нагрузка может быть сложной.

Полезные нагрузки уведомлений используют структуру данных JSON.

#### Пример payload

```json
{
    "notification_id": 123,
    "url": "https://example.com/main_action",
    "title": "Notification title",
    "action": "app|browser|deeplink|self-check",
    "message": "Notification message",
    "image": "https://example.com/image.jpg",
    "actions": [
        {"title": "Action 1", "action": "app|browser|deeplink", "url": "https://example.com/action1"}
    ],
    "sound": "default",
    "aps": {
        "alert": {"title": "Notification title", "body": "Notification message"},
        "mutable-content": 1
    },
    "attributes": {
        "event_type": "campaign",
        "campaign_id": "123456",
        "campaign_name": "Campaign name",
        "action_id": 1,
        "action_type": "mobile notification",
        "action_name": "Action 1",
        "campaign_policy": "policy",
        "consent_category": "General consent",
        "subject": "Subject",
        "language": "en",
        "platform": "ios|android",
        "sent_timestamp": 1631234567.89,
        "recipient": "user@example.com"
    },
    "url_params": {"param1": "value1", "param2": "value2"},
    "source": "xnpe_platform",
    "silent": false,
    "has_tracking_consent": true,
    "consent_category_tracking": "Tracking consent name"
}
```