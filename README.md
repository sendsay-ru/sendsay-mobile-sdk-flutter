**English** | [Русский](README.ru.md)

<p align="center">
  <img src="./docs/img/sendsay-logo.png?raw=true" alt="Sendsay"/>
</p>

# Flutter Sendsay SDK

Flutter Sendsay SDK integrates your mobile application with
[Sendsay CDP](https://www.sendsay.ru/) and tracks customer behavior in your app.
Integrating the SDK lets you send push notifications and track customer events
and properties.

The SDK wraps the
[native Android SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-android)
and the [native iOS SDK](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios).

> Flutter 3.35.4 or later is strongly recommended when testing on devices running
> iOS 26 or later. See
> [Flutter issue #175490](https://github.com/flutter/flutter/issues/175490).
> You must also satisfy the Dart SDK requirement below.

## Supported platforms and requirements

- Android: API level 24 or later.
- iOS: version 13.0 or later.
- Dart: `>=3.12.0 <4.0.0`, as declared in `pubspec.yaml`.
- Flutter: a release that bundles Dart 3.12.0 or later (below Dart 4.0.0).

## Getting started

Add Flutter Sendsay SDK to your application's `pubspec.yaml`:

```yaml
dependencies:
  sendsay: ^0.1.5
```

Then install the dependencies:

```sh
flutter pub get
```

### iOS setup

The minimum supported iOS version is 13.0. You may need to update the platform
setting in your application's `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

Install the CocoaPods dependencies:

```sh
cd ios
pod install
```

### Android setup

The minimum supported Android API level is 24. Set your application's Android
`minSdk` to 24 or later.

## Documentation

The linked integration guides are currently in Russian. Items marked as work in
progress retain the status shown in the original README.

- [Initial SDK setup](docs/setup.md)
  - [Configuration](docs/configuration.md)
  - [Authorization](docs/authorization.md)
  - [Data flushing](docs/data-flushing.md)
- [Tracking](docs/tracking.md)
- [Universal links and app links](docs/app-links.md) (work in progress)
- [Push notifications](docs/push-notifications.md)
  - [Apple Push Notification service (APNs) setup](docs/push-ios.md)
  - [Firebase Cloud Messaging setup](docs/push-android.md)
- Data fetching (work in progress)
- In-app personalization (work in progress)
  - In-app messages (work in progress)
  - In-app content blocks (work in progress)
- In-app Inbox (work in progress)
- Segmentation (work in progress)
- [Development](docs/development.md)
- [Example application](docs/example-app.md)

## Release notes

See the [changelog](CHANGELOG.md) for changes and known limitations, including
those affecting version 0.1.4.
