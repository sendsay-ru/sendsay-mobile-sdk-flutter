---
title: Links
excerpt: Enable and track Android App Links and iOS Universal Links in your app using the Flutter SDK
slug: flutter-sdk-links
categorySlug: integrations
parentDocSlug: flutter-sdk
---

Ссылки Android App Links и iOS Universal Links позволяют ссылкам, отправленным через Sendsay CDP, открываться непосредственно в вашем мобильном приложении без каких-либо перенаправлений, которые могли бы ухудшить пользовательский опыт.

На этой странице описаны шаги, необходимые для поддержки и отслеживания входящих ссылок App Links и Universal Links в вашем приложении с помощью Flutter SDK.

## Реализация и отслеживание ссылок App Links и Universal Links

В официальной [документации Flutter](https://docs.flutter.dev/ui/navigation/deep-linking) описано, как настроить приложение и как обрабатывать входящие ссылки. Нам просто нужно добавить отслеживание в Sendsay.

> 👍
>
> Когда приложение открывается по App Link или Universal Link при отсутствии активной сессии, вновь запущенная сессия будет содержать параметры трекинга из ссылки.


### Android

Для работы App Links не требуется никаких изменений.

Чтобы отслеживать ссылки в CDP Sendsay, необходимо добавить 2 метода в `MainActivity`, которые будут реагировать на входящие намерения:

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

Ваш `AppDelegate` должен вызывать `SwiftSendsayPlugin.continueUserActivity(userActivity)`, чтобы Universal Links работали.

#### С SendsayFlutterAppDelegate

Если ваш `AppDelegate` уже расширяет `SendsayFlutterAppDelegate`, никаких изменений не требуется.

#### Без SendsayFlutterAppDelegate

Если вы не используете `SendsayFlutterAppDelegate`, вы должны реализовать метод и вызвать `SwiftSendsayPlugin`:

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
