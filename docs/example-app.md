---
title: Example app
excerpt: Build, run, and navigate the example app included with the Flutter SDK
slug: flutter-sdk-example-app
categorySlug: integrations
parentDocSlug: flutter-sdk
---

Sendsay Flutter SDK включает в себя пример приложения, которое можно использовать в качестве эталонной реализации. Вы можете скомпилировать и запустить приложение, протестировать функции CDP Sendsay и сравнить код и поведение вашей реализации с ожидаемым поведением и кодом в примере приложения.

## Необходимые условия

Для компиляции и запуска примера приложения необходимо установить следующее программное обеспечение:
- [Flutter SDK](https://docs.flutter.dev/tools/sdk)
- [Git](https://git-scm.com/)
- [Android Studio](https://developer.android.com/studio) с виртуальным или физическим устройством, настроенным для запуска приложения на Android
- [Xcode](https://developer.apple.com/xcode/) and [CocoaPods](https://cocoapods.org/) с виртуальным или физическим устройством, настроенным для запуска приложения на iOS

> 👍
>
> Если вы новичок в Flutter, следуйте руководству Flutter «Начало работы» (https://docs.flutter.dev/get-started/install).

## Сборка и запуск примера приложения

1. Клонируйте репозиторий [sendsay-flutter-sdk](https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter) на GitHub:
   ```shell
   git clone https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter.git
   ```
2. Войдите в каталог `example`, содержащий пример приложения:
   ```shell
   cd sendsay-flutter-sdk/example
   ```
3. Чтобы запустить приложение на iOS:
    1. Запустите CocoaPods в каталоге `ios`, чтобы установить зависимости:
       ```shell
       cd ios
       pod install
       cd ..
       ```
    2. Подключите виртуальное или физическое устройство iOS.
    3. Запустите приложение:
       ```shell
       flutter run
       ```
4. Чтобы запустить приложение на Android:
    1. Подключите виртуальное или физическое устройство Android.
    2. Запустите приложение:
       ```shell
       flutter run --flavor fcm
       ```
       В качестве альтернативы используйте `--flavor hms` для устройств Huawei без служб GooglePlay, но с HMS Core.
       > 👍
       >
       > Если вы используете Visual Studio Code, вы можете создать [конфигурацию запуска](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations) для использования флага flavor.

> 📘
>
> Чтобы включить push-уведомления в примере приложения, необходимо также настроить [интеграцию с Firebase или интеграцию с Huawei](https://docs.sendsay.ru/other-channels/mobile-push/how-to-connect-mobile-push#%D0%BF%D0%B0%D1%80%D0%B0%D0%BC%D0%B5%D1%82%D1%80%D1%8B-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D1%8F) в веб-приложении Sendsay.

## Навигация по приложению-примеру

![Экраны приложения-примера (iOS)](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-flutter/main/docs/img/example-app-flutter-ios.png)

При запуске приложения в симуляторе вы увидите страницу **ConfigPage**. Введите [ID проекта, токен API и базовый URL API](https://docs.sendsay.ru/other-channels/mobile-push/how-to-connect-mobile-push#%D0%BF%D0%B0%D1%80%D0%B0%D0%BC%D0%B5%D1%82%D1%80%D1%8B-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D1%8F). При желании отключите «Automatic Session Tracking» с помощью переключателя (по умолчанию включено). Затем нажмите «Настроить», чтобы [инициализировать SDK](../docs/setup.md#инициализируйте-sdk).
> [`config.dart`](https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter/blob/main/example/lib/page/config.dart)

На **главной странице** имеется несколько кнопок для тестирования различных функций SDK.
> [`home.dart`](https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter/blob/main/example/lib/page/home.dart)

- В разделе `Push events` (События push) вы можете `Request Push Authorization` (Запросить авторизацию push) и проверить, `Configured?` (Настроены ли?) push-уведомления.

- В разделе `Customer` (Клиент) вы можете получить мягкий ID клиента («Get Cookie»), `Identify` (Идентифицировать) клиента (используя жестко запрограммированный ID «test-user-1@test.com») или `Anonymize` (Анонимизировать) клиента.

- В разделе `Fetch` вы можете получить «Согласия» и «Рекомендации» клиента.`

- В разделе `Flush Mode` вы можете «Получить/Get» и «Установить/Set» режим очистки, а также запустить ручную `Очистку`.`

- В разделе `Flush Period` вы можете настроить период очистки с помощью ползунка и кнопки `Установить`.`

- В разделе `Track` вы можете отслеживать `Событие` (жестко запрограммированное событие «event_name» с некоторыми примерными свойствами) и, если вы отключили автоматическое отслеживание сеансов, вы можете вручную отслеживать `Начало сеанса` и `Окончание сеанса`.`

- В разделе `Trigger in-app messages by event` вы можете отслеживать различные тестовые события, которые можно использовать для запуска встроенных сообщений во время тестирования:
    - `Modal` (отслеживание события `test_msg_modal`)
    - `Fullscreen` (отслеживание события `test_msg_fullscreen`)
    - `Slide-in` (отслеживание события `test_msg_slide`)
    - `Alert` (отслеживание события `test_msg_alert`)

- В разделе `Log Level` вы можете «Получить/Get» текущий уровень журнала.

- В разделе «Входящие сообщения приложения» вы можете получить доступ к «Входящим сообщениям приложения», «Загрузить все» сообщения, «Загрузить первое» сообщение и «Пометить первое как прочитанное».

- С помощью кнопки «In App CB Example Page» вы можете перейти на страницу **InAppCbPage** для тестирования блоков контента в приложении(в разработке). Используйте идентификаторы заполнителей `example_top` и `example_list` для соответствующих заполнителей. Используйте идентификаторы заполнителей `ph_x_example_iOS` и `ph_x_example_Android` для тестирования блоков контента, специфичных для платформы, в заполнителе с меткой «platformSpecificPlaceholderId».
  > [in_app_cb_page.dart](https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter/blob/main/example/lib/page/in_app_cb_page.dart)

Опробуйте различные функции приложения, затем найдите профиль клиента в веб-приложении CDP Sendsay (в разделе «Клиенты»), чтобы увидеть свойства и события, отслеживаемые SDK.

По умолчанию клиент отслеживается анонимно с помощью мягкого идентификатора cookie. Вы можете посмотреть значение cookie в журналах и найти соответствующий профиль в веб-приложении CDP Sendsay.

Если вы использовали кнопку «Идентифицировать», клиента можно найти в веб-приложении CDP Sendsay по тестовому адресу электронной почты (test-user-1@test.com).

![Примеры экранов приложения (Android)](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-flutter/main/docs/img/example-app-flutter-android.png)

## Устранение неполадок

Если при запуске приложения-примера возникли проблемы, могут помочь следующие действия:

- В каталоге `example` запустите команду `flutter clean`, а затем `flutter pub get`.
- Если приложение не запускается на Android, возможно, вы забыли включить флаг требуемого окружения `--flavor fcm` или `--flavor hms`.