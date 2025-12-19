---
title: SDK development
excerpt: Work with the Flutter SDK source code.
slug: flutter-sdk-development
categorySlug: integrations
parentDocSlug: flutter-sdk
---

## Справочник по работе SDK

Проект состоит из кода Flutter в папке `/lib`, нативного модуля Android в `/android` и нативного модуля iOS в `/ios`. Чтобы увидеть функциональность SDK в действии, мы предоставляем [пример приложения](../docs/example-app.md), который вы можете найти в `/example`.

### Flutter

* Для запуска модульных тестов мы используем [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html). Для запуска модульных тестов используйте `flutter test`.

### Android

Нативный модуль Android написан на Kotlin, так как он также используется для нашего нативного [Android SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-android).

* Для запуска модульных тестов мы используем [JUnit4](https://junit.org/junit4/). Для запуска модульных тестов используйте `./gradlew test`.

### iOS

Нативный модуль iOS написан на Swift, так как этот язык также используется для нашего нативного [iOS SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios).

* Мы используем [CocoaPods](https://cocoapods.org/) для управления зависимостями. Вы увидите файл `Podfile`, который определяет зависимости для «автономного» проекта Xcode, который мы используем для разработки нативного модуля iOS. Эти поды не будут частью выпущенного пакета, файл `.podspec` находится на уровне пакета. Запустите `pod install` перед открытием проекта Xcode и началом разработки.
* Мы используем [quick](https://github.com/Quick/Quick) для написания тестов, вы можете запускать их прямо в XCode.
