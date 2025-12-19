---
title: Authorization
excerpt: Full authorization reference for the Flutter SDK
slug: flutter-sdk-authorization
categorySlug: integrations
parentDocSlug: flutter-sdk-setup
---
# Авторизация

SDK обменивается данными с CDP Sendsay через HTTPS. SDK поддерживает стандартную **авторизацию по токену** для доступа к мобильному API.

## Авторизация по токену

Режим авторизации по умолчанию обеспечивает [публичный доступ к API](https://docs.sendsay.ru/sendsay-api) с использованием ключа API в качестве токена.

Авторизация с помощью токена по умолчанию используется для следующих эндпоинтов API:

* `POST /track/v2/projects/<PROJECT_ID>/customers` для отслеживания данных клиента
* `POST /track/v2/projects/<PROJECT_ID>/customers/events` для отслеживания событий
* `POST /track/v2/projects/<PROJECT_ID>/campaigns/clicks` для отслеживания событий кампаний (рекламных кампаний)
* `POST /data/v2/projects/<PROJECT_ID>/consent/categories` для получения согласий

[//]: # (* `POST /webxp/s/<PROJECT_ID>/inappmessages?v=1` для получения InApp-сообщений)

[//]: # (* `POST /webxp/projects/<PROJECT_ID>/appinbox/fetch` для получения данных AppInbox)

[//]: # (* `POST /webxp/projects/<PROJECT_ID>/appinbox/markasread` для отметки сообщения AppInbox как прочитанного)

[//]: # (* `POST /campaigns/send-self-check-notification?project_id=<PROJECT_ID>` для части процесса самопроверки push-уведомлений)

Стандартный режим авторизации по токену обеспечивает доступ к публичным эндпоинтам мобильного API с использованием API-ключа в качестве токена.

Разработчики должны установить токен, используя параметр конфигурации `authorization` при инициализации SDK:

`<PROJECT_ID>` - ID вашего аккаунта в Sendsay

```dart
final _plugin = SendsayPlugin();
...
final config = SendsayConfiguration(
    ...
    projectToken: "<PROJECT_ID>",
    authorizationToken: "<YOUR_API_KEY>",
    ...
);
final configured = await _plugin.configure(config);
```

> ❗️
>
> Пожалуйста, подумайте о более безопасном хранении ключа API. Android предлагает несколько вариантов, таких как [KeyStore](https://developer.android.com/training/articles/keystore) или [Encrypted Shared Preferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences).
> Flutter также имеет [аналоги](https://pub.dev/packages?q=secure+storage) этих вариантов.
