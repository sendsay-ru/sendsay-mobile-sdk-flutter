---
title: Authorization
excerpt: Full authorization reference for the Flutter SDK
slug: flutter-sdk-authorization
categorySlug: integrations
parentDocSlug: flutter-sdk-setup
---
# Авторизация

SDK обменивается данными с CDP Sendsay через HTTPS. Flutter SDK поддерживает стандартную **авторизацию по токену** для доступа к мобильному API.

## Авторизация по токену

Авторизация по токену даёт доступ к [публичным эндпоинтам мобильного API](https://docs.sendsay.ru/sendsay-api). Для этого используйте API-ключ в качестве токена.

В этом режиме SDK работает со следующими эндпоинтами API:

* `POST /track/v2/projects/<PROJECT_ID>/customers` — отслеживание данных клиента;
* `POST /track/v2/projects/<PROJECT_ID>/customers/events` — отслеживание событий;
* `POST /track/v2/projects/<PROJECT_ID>/campaigns/clicks` — отслеживание событий кампаний;
* `POST /data/v2/projects/<PROJECT_ID>/consent/categories` — получение информации о согласиях.

[//]: # (* `POST /webxp/s/<PROJECT_ID>/inappmessages?v=1` для получения InApp-сообщений)

[//]: # (* `POST /webxp/projects/<PROJECT_ID>/appinbox/fetch` для получения данных AppInbox)

[//]: # (* `POST /webxp/projects/<PROJECT_ID>/appinbox/markasread` для отметки сообщения AppInbox как прочитанного)

[//]: # (* `POST /campaigns/send-self-check-notification?project_id=<PROJECT_ID>` для части процесса самопроверки push-уведомлений)

Для работы SDK необходимо указать токен авторизации при инициализации, используя параметр конфигурации `authorization`:

- `<PROJECT_ID>` — ID вашего аккаунта в Sendsay;
- `<YOUR_API_KEY>` — API-ключ.

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
После инициализации SDK будет использовать указанный API-ключ для выполнения всех запросов к мобильному API.

> ❗️
>
> Рекомендуется обеспечить безопасное хранение API-ключа. 
> Для Android можно использовать, например, [KeyStore](https://developer.android.com/training/articles/keystore) или [Encrypted Shared Preferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences).
> Для Flutter доступны аналогичные решения, например, пакеты из категории [secure storage](https://pub.dev/packages?q=secure+storage)/
