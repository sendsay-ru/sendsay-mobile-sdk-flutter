[English](README.md) | **Русский**

<p align="center">
  <img src="./doc/img/sendsay-logo.png?raw=true" alt="Sendsay"/>
</p>


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

- [Первоначальная настройка SDK](doc/setup.md)
  - [Конфигурация](doc/configuration.md)
  - [Авторизация](doc/authorization.md)
  - [Отправка данных](doc/data-flushing.md)
- [Отслеживание](doc/tracking.md)
- [Универсальные ссылки](doc/app-links.md) (продолжает дорабатываться)
- [Push-уведомления](doc/push-notifications.md)
  - [Настройка Apple Push Notification Service(APNs)](doc/push-ios.md)
  - [Настройка Google(Firebase) Messages Service](doc/push-android.md)
- Получение данных (в разработке)
- In-app персонализация (в разработке)
  - In-app сообщения (в разработке)
  - Блоки контента в приложении (в разработке)
- In-app Inbox (в разработке)
- Сегментация (в разработке)
- [Разработка](doc/development.md)
- [Пример приложения](doc/example-app.md)


## Примечания к версии

[Примечания к версии](CHANGELOG.md) для Sendsay SDK
