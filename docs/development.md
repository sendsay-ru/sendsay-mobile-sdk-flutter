---
title: SDK development
excerpt: Work with the Flutter SDK source code.
slug: flutter-sdk-development
categorySlug: integrations
parentDocSlug: flutter-sdk
---

## Справочник по работе SDK

Flutter SDK состоит из нескольких частей:
- Flutter-код — в каталоге `/lib`;
- нативный модуль Android — в каталоге `/android`;
- нативный модуль iOS — в каталоге `/ios`.

Чтобы посмотреть, как SDK работает в реальном приложении, вы можете использовать [пример приложения](../docs/example-app.md), расположенный в каталоге `/example`.

### Flutter

Flutter-часть SDK содержит общий код, используемый на всех платформах.

* Для написания и запуска модульных тестов используется пакет [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html). 
* Для запуска тестов выполните команду:
    ```
    flutter test
    ```

### Android

Нативный модуль Android написан на Kotlin. Он использует ту же кодовую базу, что и нативный [Android SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-android).

* Для модульного тестирования используется [JUnit4](https://junit.org/junit4/). 
* Для запуска тестов выполните команду: 
    ```
    ./gradlew test
    ```

### iOS

Нативный модуль iOS написан на Swift и использует ту же кодовую базу, что и нативный [iOS SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios).

* Для управления зависимостями используется [CocoaPods](https://cocoapods.org/). 
    - В проекте присутствует файл `Podfile`, который описывает зависимости для отдельного Xcode-проекта, используемого при разработке нативного iOS-модуля. 
    - Эти зависимости не входят в опубликованный SDK — для этого используется файл .podspec, расположенный в корне пакета.
    - Перед открытием проекта в Xcode выполните команду `pod install`.
* Для написания и запуска тестов используется фреймворк [Quick](https://github.com/Quick/Quick). Тесты можно запускать напрямую из Xcode.
