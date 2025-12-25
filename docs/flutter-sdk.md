---
title: Flutter SDK
excerpt: Sendsay SDK for Flutter
slug: flutter-sdk
categorySlug: integrations
---

# Что такое Flutter Sendsay SDK

Flutter Sendsay SDK позволяет интегрировать ваше мобильное приложение с [Sendsay CDP](https://www.sendsay.ru/) и отслеживать поведение пользователей. С его помощью вы можете отправлять push-уведомления, фиксировать события и свойства клиентов.

Flutter SDK реализован как обёртка над нативным SDK:
- [Android SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-android)
- [iOS SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios).

> Если вы тестируете приложение на устройствах с iOS 16+*, рекомендуется использовать Flutter версии 3.35.4 или выше. Подробнее — в [обсуждении](https://github.com/flutter/flutter/issues/175490) репозитория Flutter.

## Начало работы

Для подключения Flutter SDK добавьте зависимость в файл `pubspec.yaml` вашего проекта:

```
sendsay: x.y.z
```
Затем выполните команду:

```
flutter pub get
```

### Установка для iOS:

1. Перейдите в каталог iOS:

```
cd ios
```

2. Установите зависимости с помощью CocoaPods:

```
pod install
```

Минимальная поддерживаемая версия iOS для Sendsay SDK — **13.0**. При необходимости измените версию платформы в файле ios/Podfile:

```
platform :ios, '13.0'
```

### Установка для Android

Минимальный поддерживаемый уровень API Android для Sendsay Flutter SDK — **24**.

## Документация

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
