---
title: Tracking Consent
excerpt: Manage tracking consent using the Flutter SDK.
slug: flutter-sdk-tracking-consent
categorySlug: integrations
parentDocSlug: flutter-sdk-tracking
---

# Управление согласием на отслеживание

В зависимости от локальных требований к защите данных, доступ к данным на устройстве пользователя может требовать явного согласия. Для соблюдения таких требований в CDP Sendsay предусмотрена автономная функция **tracking consent** (согласие на отслеживание).

При включённой функции tracking consent SDK учитывает согласие пользователя при отслеживании событий, связанных с push-уведомлениями, in-app сообщениями, блоками контента в приложении и пушах.

## Как SDK обрабатывает tracking consent

Если функция tracking consent **включена**, Sendsay передаёт атрибут `has_tracking_consent` в составе push-уведомлений, in-app сообщений и данных блоков контента. SDK отслеживает события, **только если** значение `has_tracking_consent` равно `true`.

Если функция tracking consent отключена, атрибут `has_tracking_consent` не передаётся. В этом случае SDK считает согласие полученным и отслеживает события без ограничений.

Для событий клика значение `has_tracking_consent` может быть переопределено. Если **action URL** содержит query-параметр `xnpe_force_track=true`, SDK выполнит отслеживание независимо от значения `has_tracking_consent`.

События, отслеженные с помощью принудительного трекинга, будут содержать дополнительное свойство `tracking_forced = true`.

## Отслеживание событий с учётом tracking consent

Ниже описано, как SDK обрабатывает различные типы событий.

### Доставка push-уведомлений

SDK отслеживает доставку push-уведомлений при вызове:
- `SendsayPlugin().trackDeliveredPush`
- `SendsayPlugin.handleRemoteMessage`

Событие доставки отслеживается, если выполняется одно из условий:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`.

Чтобы отслеживать доставку push-уведомлений без учёта tracking consent, используйте:
- `SendsayPlugin().trackDeliveredPushWithoutTrackingConsent`

### Клики по push-уведомлениям

SDK отслеживает клики по push-уведомлениям при вызове:
- `SendsayPlugin().trackClickedPush`

Событие клика отслеживается, если выполняется одно из условий:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`;
- **action URL** содержит `xnpe_force_track=true`.

Для отслеживания кликов без учёта tracking consent используйте:
- `SendsayPlugin().trackPushOpenedWithoutTrackingConsent`

### Клики по in-app сообщениям

SDK отслеживает клики по in-app сообщениям при вызове:
- `SendsayPlugin().trackInAppMessageClick`

Событие отслеживается, если выполняется одно из условий:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`;
- **action URL** содержит `xnpe_force_track=true`.

Для игнорирования tracking consent используйте:
- `SendsayPlugin().trackInAppMessageClickWithoutTrackingConsent`

### Закрытие in-app сообщений

SDK отслеживает закрытие in-app сообщений при вызове:
- `SendsayPlugin().trackInAppMessageClose`

Событие отслеживается, если:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`.

Для отслеживания без учёта tracking consent используйте:
- `SendsayPlugin().trackInAppMessageCloseWithoutTrackingConsent`

### Открытие сообщений App Inbox

SDK отслеживает открытие сообщений App Inbox при вызове:
- `SendsayPlugin().trackAppInboxOpened`

Событие отслеживается, если выполняется одно из условий:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`;
- App Inbox загружен, и переданный `MessageItem` присутствует в нём.

Для игнорирования tracking consent используйте:
- `SendsayPlugin().trackAppInboxOpenedWithoutTrackingConsent`

### Клики по действиям App Inbox

SDK отслеживает клики по действиям App Inbox при вызове:
- `SendsayPlugin().trackAppInboxClick`

Событие отслеживается, если выполняется одно из условий:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`;
- **action URL** содержит `xnpe_force_track=true`.

Для отслеживания без учёта tracking consent используйте:
- `SendsayPlugin().trackAppInboxClickWithoutTrackingConsent`

### Показ блоков контента

SDK отслеживает показ блоков контента при вызове:
- `SendsayPlugin().trackInAppContentBlockShown`

Событие отслеживается, если:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`.

Для игнорирования tracking consent используйте:
- `SendsayPlugin().trackInAppContentBlockShownWithoutTrackingConsent`

### Клики по блокам контента

SDK отслеживает клики по блокам контента при вызове:
- `SendsayPlugin().trackInAppContentBlockClick`

Событие отслеживается, если выполняется одно из условий:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`;
- **action URL** содержит `xnpe_force_track=true`.

Для отслеживания без учёта tracking consent используйте:
- `SendsayPlugin().trackInAppContentBlockClickWithoutTrackingConsent`

### Закрытие блоков контента

SDK отслеживает закрытие блоков контента при вызове:
- `SendsayPlugin().trackInAppContentBlockClose`

Событие отслеживается, если:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`.

Для игнорирования tracking consent используйте:
- `SendsayPlugin().trackInAppContentBlockCloseWithoutTrackingConsent`

### Ошибки блоков контента

SDK отслеживает ошибки блоков контента при вызове:
- `SendsayPlugin().trackInAppContentBlockError`

Событие отслеживается, если:
- функция tracking consent отключена;
- функция tracking consent включена и `has_tracking_consent = true`.

Для отслеживания ошибок без учёта tracking consent используйте:
- `SendsayPlugin().trackInAppContentBlockErrorWithoutTrackingConsent`
