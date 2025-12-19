---
title: Flutter SDK
excerpt: Sendsay SDK for Flutter
slug: flutter-sdk
categorySlug: integrations
---

# Что такое Flutter Sendsay SDK
Flutter Sendsay SDK позволяет интегрировать ваше мобильное приложение с [Sendsay CDP](https://www.sendsay.ru/) и отслеживать поведение ваших клиентов в приложении. Интеграция SDK в ваше приложение позволит вам отправлять push-уведомления и отслеживать события и свойства клиентов.

Этот SDK реализован как обертка над [native Android SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-android) и [native iOS SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios).

> Очень рекомендуется обновить Flutter до версии 3.35.4 и выше, если вы тестируете приложение на устройствах с iOs 26+ (https://github.com/flutter/flutter/issues/175490).

## Начало работы

В файле `pubspec.yaml` вашего проекта добавьте зависимость Flutter Sendsay SDK:
```
sendsay: x.y.z
```
и выполните
* `$ flutter pub get`

### установка для iOS:

* `$ cd ios`
* `$ pod install`

Минимальная поддерживаемая версия iOS для Sendsay SDK — 13.0. Возможно, вам потребуется изменить версию iOS в первой строке вашего `ios/Podfile` на `platform :ios, '13.0'` или выше.

### установка для Android

Минимальный поддерживаемый уровень API Android для Sendsay SDK — 24.

- [Первоначальная настройка SDK](docs/setup.md)
  - [Конфигурация](docs/configuration.md)
  - [Авторизация](docs/authorization.md)
  - [Отправка данных](docs/data-flushing.md)
- [Отслеживание](docs/tracking.md)
- [Универсальные ссылки](docs/app-links.md) (продолжает дорабатываться)
- [Push-уведомления](docs/push-notifications.md)
  - [Настройка Apple Push Notification Service(APNs)](docs/push-ios.md)
  - [Настройка Google(Firebase) Messages Service](docs/push-android.md)
- Получение данных (в разработке)
- In-app персонализация (в разработке)
  - In-app сообщения (в разработке)
  - Блоки контента в приложении (в разработке)
- In-app Inbox (в разработке)
- Сегментация (в разработке)
- [Разработка](docs/development.md)
- [Пример приложения](docs/example-app.md)
