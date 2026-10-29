---
title: Initial SDK setup
excerpt: Install and configure the Flutter SDK
slug: flutter-sdk-setup
categorySlug: integrations
parentDocSlug: flutter-sdk
---
## Установка SDK

SDK Sendsay Flutter можно установить или обновить через зависимость в файле [pubspec](https://docs.flutter.dev/tools/pubspec) вашего приложения. Для настройки iOS-приложения требуется [CocoaPods](https://cocoapods.org/).

> 📘
>
> Последнюю версию SDK Sendsay Flutter можно найти по ссылке https://github.com/sendsay-ru/sendsay-mobile-sdk-flutter/tags или https://pub.dev/packages/sendsay.

### Добавить зависимость

В файле `pubspec.yaml` вашего проекта добавьте зависимость от Sendsay Flutter SDK в раздел `dependencies:`:

```yaml
dependencies:
  sendsay: ^0.1.0
```

### Настройка iOS

Чтобы разрешить зависимости SDK Sendsay для iOS-приложения, сначала перейдите в каталог `ios` в вашем проекте:

```shell
cd ios
```

Затем выполните следующую команду:

```shell
pod install
```

Минимальная поддерживаемая версия iOS для Sendsay SDK — 13.0. Возможно, вам потребуется изменить версию iOS в первой строке вашего `ios/Podfile` на `platform :ios, '13.0'` или выше.

### Настройка Android

Минимальный поддерживаемый уровень API Android для Sendsay SDK — 24. Возможно, вам потребуется установить или обновить значение `minSdk` в файле `android/app/build.gradle` до `24` или выше:

```gradle
android {
    ...
    defaultConfig {
        ...
        minSdk 24
    }
```

## Инициализируйте SDK.

Теперь, когда вы установили SDK в свой проект, необходимо импортировать, настроить и инициализировать SDK в коде вашего приложения.

Необходимые параметры конфигурации: `projectToken`, `authorizationToken` и `baseURL`. Их можно найти в веб-приложении app.sendsay.ru, в разделе `Подписчики` > `Мобильное приложение` > `Настройки приложения и импорта` > `Работа через SDK`.

> 📘
>
> Подробности см. в [Управление доступом к мобильным SDK](https://docs.sendsay.ru/sendsay-api/how-to-get-apikey).

```dart
import 'package:sendsay/sendsay.dart';
```

Инициализация:

```dart
final _plugin = SendsayPlugin();
final configuration = SendsayConfiguration(
  projectToken: 'YOUR_PROJECT_TOKEN',
  authorizationToken: 'YOUR_API_KEY',
  // значение baseUrl по умолчанию это https://mobi.sendsay.ru/xnpe/v100
  baseUrl: 'YOUR_API_BASE_URL', 
);
_plugin.configure(configuration).catchError((error) {
  print('Error: $error');
  return false;
});
```

### Настройте SDK только один раз

Код приложения на Flutter можно перезагрузить без перезапуска нативной части приложения. Это ускоряет процесс разработки, но также означает, что нативный код обычно продолжает работать, как ни в чем не бывало. Вам нужно настроить SDK только один раз. При разработке с включенной функцией hot reload, перед настройкой SDK, необходимо проверить `SendsayPlugin().isConfigured()`.

```dart
Future<void> configureSendsay(SendsayConfiguration configuration) {
  try {
    if (!await _plugin.isConfigured()) {
      _plugin.configure(configuration);
    } else {
      print("Sendsay SDK already configured.");
    }
  } catch (error) {
    print('Error: $error');
  }
}
```

### Готово!

На этом этапе SDK активен и должен отслеживать сеансы в вашем приложении.

## Другие настройки SDK

### Расширенные настройки

SDK можно дополнительно настроить, установив дополнительные свойства объекта `SendsayConfiguration`. Полный список доступных параметров настройки см. в документации [Настройка](../doc/configuration.md).

### Уровень Логирования

SDK поддерживает следующие уровни логирования, определенные в `LogLevel`:

| Уровень Логирования | Описание |
| ----------| --------- -- |
| `off`     | Отключает все логирования в журнале |
| `error`   | Серьезные ошибки или критические проблемы |
| `warning` | Предупреждения и рекомендации + `error` |
| `info`    | Информационные сообщения + `warning` + `error` |
| `debug`   | Информация об отладке + `info` + `warning` + `error`  |
| `verbose` | Информация обо всех действиях SDK + `debug` + `info` + `warning` + `error`. |

Уровень логирования по умолчанию — `info`. При разработке или отладке может быть полезно установить уровень логирования на `debug` или `verbose`.

Уровень логирования можно установить во время выполнения следующим образом:

```dart
_plugin.setLogLevel(LogLevel.verbose);
```

### Выгрузка данных

Прочитайте раздел [Выгрузка данных](../doc/data-flushing.md), чтобы узнать больше о том, как SDK загружает данные в Sendsay API и как настроить это поведение под свои нужды.
