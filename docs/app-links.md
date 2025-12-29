---
title: Links
excerpt: Enable and track Android App Links and iOS Universal Links in your app using the Flutter SDK
slug: flutter-sdk-links
categorySlug: integrations
parentDocSlug: flutter-sdk
---

Ссылки **Android App Links** и **iOS Universal Links** позволяют ссылкам, отправленным через Sendsay CDP, открываться напрямую в мобильном приложении без промежуточных перенаправлений. Это улучшает пользовательский опыт и обеспечивает корректную передачу данных для отслеживания.

На этой странице описано, как настроить поддержку и отслеживание входящих App Links и Universal Links в приложении с использованием Flutter SDK.

## Реализация и отслеживание App Links и Universal Links

В официальной [документации Flutter](https://docs.flutter.dev/ui/navigation/deep-linking) описано, как настроить приложение для обработки входящих ссылок на уровне платформы. Со стороны Sendsay необходимо только добавить обработку входящих ссылок для их отслеживания.

> 👍
>
> Если приложение открывается по App Link или Universal Link при отсутствии активной сессии, новая сессия будет содержать параметры трекинга, переданные в ссылке.


### Android

Для поддержки **Android App Links** дополнительных изменений в конфигурации SDK не требуется.

Чтобы отслеживать ссылки в CDP Sendsay, необходимо в `MainActivity` добавить 2 метода, которые будут реагировать на входящие намерения:

```kotlin
package ru.sendsay.example

import android.content.Intent
import android.os.Bundle
import ru.sendsay.SendsayPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Add this call:
        SendsayPlugin.Companion.handleCampaignIntent(intent, applicationContext)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        // Add this call:
        SendsayPlugin.Companion.handleCampaignIntent(intent, applicationContext)
        super.onNewIntent(intent)
    }
}
```

### iOS

Для поддержки **iOS Universal Links** ваш `AppDelegate` должен вызывать `SwiftSendsayPlugin.continueUserActivity(userActivity)`.

#### С SendsayFlutterAppDelegate

Если ваш `AppDelegate` уже расширяет `SendsayFlutterAppDelegate`, дополнительная настройка не требуется — Universal Links будут обрабатываться автоматически.

#### Без SendsayFlutterAppDelegate

Если вы не используете `SendsayFlutterAppDelegate`, необходимо вручную реализовать метод и вызвать `SwiftSendsayPlugin`:

```swift
    open override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        SwiftSendsayPlugin.continueUserActivity(userActivity)
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
```
