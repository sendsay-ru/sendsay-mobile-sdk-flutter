---
title: Configuration
excerpt: Full configuration reference for the Flutter SDK
slug: flutter-sdk-configuration
categorySlug: integrations
parentDocSlug: flutter-sdk-setup
---

Эта страница предоставляет обзор всех параметров конфигурации для SDK и несколько примеров того, как инициализировать SDK с различными конфигурациями.

> 📘
>
> Инструкции см. в разделе [Инициализация SDK](https://docs.sendsay.ru/sources-and-events/mobile-app/#%D0%B8%D0%BD%D1%82%D0%B5%D0%B3%D1%80%D0%B0%D1%86%D0%B8%D1%8F-%D1%81-%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B5%D0%BC-%D1%87%D0%B5%D1%80%D0%B5%D0%B7-sdk).

## Параметры конфигурации

* `projectToken` **(обязательный)**
  * Ваш токен проекта. Вы можете найти его в веб-приложении CDP Sendsay в разделе `Настройки аккаунта` > `Основной логин` > `Скопировать`.

* `authorization` **(обязательный)**
  * Варианты: `.none` или `.token(token)`.
  * Токен должен быть **публичным** ключом CDP Sendsay.
  * Для получения дополнительной информации обратитесь к [документации Sendsay API](https://docs.sendsay.ru/other-channels/mobile-push/how-to-connect-mobile-push/#%D0%BF%D0%B0%D1%80%D0%B0%D0%BC%D0%B5%D1%82%D1%80%D1%8B-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D1%8F).

* `baseUrl`
  * Значение по умолчанию: `https://mobi.sendsay.ru/xnpe/v100`.
  * Если у вас есть свой пользовательский базовый URL, вы должны установить это свойство.

* `projectMapping`
  * Если вам нужно отслеживать события в более чем одном проекте, вы можете определить информацию о проекте для "типов событий", которые должны отслеживаться несколько раз.
  * Пример:
    ```dart
    projectMapping: {
      EventType.banner: [
        SendsayProject(
          projectToken: 'other-project-token',
          authorizationToken: 'other-auth-token',
        ),
      ],
    }
    ```
  
* `defaultProperties`
  * Список свойств, которые будут добавлены ко всем событиям отслеживания.
  * Вы можете изменить эти свойства во время выполнения, вызвав `SendsayPlugin().setDefaultProperties()`.
  * Значение по умолчанию: `nil`

* `automaticSessionTracking`
  * Флаг для управления автоматическим отслеживанием событий `session_start` и `session_end`.
  * Значение по умолчанию: `true`

* `sessionTimeout`
  * Сессия - это фактическое время, проведенное в приложении. Она начинается при запуске приложения и заканчивается, когда приложение переходит в фон.
  * Это значение используется для расчета времени сессии.
  * Значение по умолчанию: `60.0` секунд.
  * Минимальное значение: `5.0` секунд.
  * **Рекомендуемое** максимальное значение: `120.0` секунд, но **абсолютный** максимум составляет `180.0` секунд. Большее значение приведет к тому, что iOS завершит сессию.
  * Подробнее читайте в разделе [Отслеживание сессий](tracking#Сессии).

* `pushTokenTrackingFrequency`
  * Указывает частоту, с которой токен APNs должен отслеживаться в CDP Sendsay.
  * Значение по умолчанию: `TokenFrequency.onTokenChange`
  * Возможные значения:
    * `.onTokenChange` - отслеживает push-токен, если он отличается от ранее отслеженного
    * `.everyLaunch` - всегда отслеживает push-токен
    * `.daily` - отслеживает push-токен раз в день

* `requirePushAuthorization`
  * SDK может проверить статус авторизации push-уведомлений ([документация Apple](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus)) и отслеживать push-токен только в том случае, если пользователь авторизован для получения push-уведомлений.
  * При отключении SDK автоматически зарегистрируется для push-уведомлений при запуске приложения и отследит токен в CDP Sendsay, чтобы ваше приложение могло получать тихие push-уведомления.
  * При включении SDK автоматически зарегистрируется для push-уведомлений, если приложение авторизовано показывать push-уведомления пользователю.
  * Значение по умолчанию: `true`

* `flushMaxRetries`
  * Управляет тем, сколько раз событие должно быть отправлено перед прерыванием. Полезно, например, в случае недоступности API или других временных ошибок.
  * Значение по умолчанию: `10`

* `advancedAuthEnabled`
  * Если установлено в `true`, SDK использует авторизацию по [токену клиента](../doc/authorization.md#авторизация) для связи с API CDP Sendsay, перечисленными в [Авторизация по токену клиента](../doc/authorization.md#авторизация-по-токену).
  * Обратитесь к [документации по авторизации](../doc/authorization.md) для получения подробностей.
  * Значение по умолчанию: `false`

[//]: # (* `inAppContentBlocksPlaceholders`)
[//]: # (  * Если установлено, все [блоки контента в приложении]&#40;https://documentation.bloomreach.com/engagement/docs/ios-sdk-in-app-content-blocks&#41; будут предварительно загружены сразу после инициализации SDK.)

* `android`
  * `AndroidSendsayConfiguration` object containing [Android-specific configuration parameters](#параметры-конфигурации-специфичные-для-android).

* `ios`
  * `IOSSendsayConfiguration` object containing [iOS-specific configuration parameters](#параметры-конфигурации-специфичные-для-ios).

### Параметры конфигурации, специфичные для Android

Следующие параметры указаны в объекте `AndroidSendsayConfiguration`. Полное определение Dart см. в [lib/src/data/model/configuration.dart](https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter/blob/main/lib/src/data/model/configuration.dart).

* `automaticPushNotification`
  * Управляет тем, будет ли SDK автоматически обрабатывать push-уведомления.
  * Значение по умолчанию: `true`

* `pushIcon`
  * Иконка, которая будет отображаться в push-уведомлении.
  * Подробности см. на https://developer.android.com/design/ui/mobile/guides/home-screen/notifications#notification-header.

* `pushAccentColor`
  * Акцентный цвет push-уведомления. Изменяет цвет маленькой иконки и кнопок уведомления. Например: `Color.GREEN`.
  * Это ID цвета, а не ID ресурса. При использовании цветов из ресурсов вы должны указать ресурс, например: `context.resources.getColor(R.color.something)`.
  * Подробности см. на https://developer.android.com/design/ui/mobile/guides/home-screen/notifications#notification-header.

* `pushChannelName`
  * Имя канала, который будет создан для push-уведомлений.
  * Доступно только для API уровня 26+. Подробности см. на https://developer.android.com/training/notify-user/channels.

* `pushChannelDescription`
  * Описание канала, который будет создан для push-уведомлений.
  * Доступно только для API уровня 26+. Подробности см. на https://developer.android.com/training/notify-user/channels.

* `pushChannelId`
  * ID канала для push-уведомлений.
  * Доступно только для API уровня 26+. Подробности см. на https://developer.android.com/training/notify-user/channels.

* `pushNotificationImportance`
  * Важность уведомлений для канала уведомлений.
  * Доступно только для API уровня 26+. Подробности см. на https://developer.android.com/training/notify-user/channels.

* `httpLoggingLevel`
  * Уровень регистрации HTTP-запросов/ответов.

* `allowWebViewCookies`
  * Флаг для включения или отключения cookies в WebViews.
  * Значение по умолчанию: `false`
  * > ❗️
    >
    > **Отказ от ответственности**:
    > * В целях безопасности cookies по умолчанию отключены в WebViews.
    > * Эта настройка влияет на все WebViews в приложении, НЕ ТОЛЬКО на те, которые используются SDK.
    > * НЕ ИЗМЕНЯЙТЕ ЭТУ НАСТРОЙКУ, если вы не знаете рисков, связанных с включением и хранением cookies.
    > * Изменив эту настройку и включив cookies в WebViews, вы берете на себя полную ответственность за любые уязвимости безопасности или инциденты, вызванные ими.

* `appInboxDetailImageInset`
  * Определяет верхний отступ изображения на экране сведений о приложении в дюймах. По умолчанию (null) будет использоваться значение `?attr/actionBarSize`, определённое в теме приложения. Это полезно в случае прозрачной панели инструментов.

### Параметры конфигурации, специфичные для iOS

Следующие параметры указаны в объекте `IOSSendsayConfiguration`. Полное определение Dart см. в [lib/src/data/model/configuration.dart](https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter/blob/main/lib/src/data/model/configuration.dart).

* `requirePushAuthorization` — УСТАРЕЛ
  * SDK может проверять статус авторизации push-уведомлений ([документация Apple](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus)) и отслеживать push-токен только в том случае, если пользователь авторизован для получения push-уведомлений.
  * Если эта функция отключена, SDK автоматически регистрируется для получения push-уведомлений при запуске приложения и отслеживает токен в CDP Sendsay, чтобы ваше приложение могло получать бесшумные push-уведомления.
  * При включении SDK автоматически регистрируется для push-уведомлений, если приложение имеет право показывать push-уведомления пользователю.
  * Если вы не используете только бесшумные уведомления, оставьте значение по умолчанию `true`.

* `appGroup`
  * **Обязательно** для того, чтобы SDK автоматически отслеживал доставленные push-уведомления. Обратитесь к документации [Push-уведомления](../doc/push-notifications.md#шаг-2-настройка-sdk) для получения подробностей.
  * appGroup используется для связи между основным приложением и расширениями уведомлений. Это обязательное поле для настройки расширенных push-уведомлений.
