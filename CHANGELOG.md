---
title: Release notes
excerpt: Sendsay Flutter SDK release notes
slug: flutter-sdk-release-notes
categorySlug: integrations
parentDocSlug: flutter-sdk
---

# Changelog

## Release Notes for 0.1.5

#### October 21, 2026

### Features

- Experimental Advertising ID support for Android and iOS is under development
  and testing. Test APIs include `get`, `track`, and `fetch`; availability varies
  by platform and native SDK version.
- `stopIntegration()` and `clearLocalCustomerData()` on Android and iOS. Cleanup
  requires an inactive SDK; iOS additionally requires the previous App Group.
- Android RuStore token handling through `handleRsmPushToken()` and native
  RuStore token entry points. See the Dart tracking limitation below.

### Changed

- Updated the native Sendsay iOS dependencies to 0.1.4 and Android dependencies to 0.1.5(RSM cause).
- Raised the Dart SDK constraint to `>=3.12.0 <4.0.0`.
- Registered the iOS plugin for the Flutter scene lifecycle and migrated the
  example application's iOS integration to `UIScene`.
- Updated the Android build configuration to Android Gradle Plugin 8.13.2,
  Kotlin 2.2.20, Java 17, and compile SDK 35. The minimum Android API level
  remains 24; the minimum iOS version remains 13.0.
- Added explicit Android/iOS package metadata while retaining the existing
  native plugin registrations.
- Translated the main README into English, preserved the Russian version in
  `README.ru.md`, and added links between the two versions.

### Fixed

- Routed iOS SSEC events through the native `trackSSEC` API and returned an error
  for unknown event types.
- Removed the Android SSEC debug error response that preceded a success response
  for the same method-channel call.
- Corrected the example application's RuStore Maven repository URL and messaging
  service integration.

### Important Migration status

- Preparation for Android built-in Kotlin and iOS Swift Package Manager support
  is in progress for the planned 0.2.0 release; validation is still pending.
- Android uses `kotlin.compilerOptions`, but the Flutter plugin still applies
  `kotlin-android`; built-in Kotlin migration is not complete.
- The iOS example integrates SwiftPM-compatible plugins, but Sendsay still uses
  CocoaPods. The Flutter plugin does not yet include its own `Package.swift`.



## Release Notes for 0.1.0

#### December 12, 2025

### Features

- Initial release with base functionality of the mobile SDKs - tracking, fetching, SSEC and CCE
  support.
- Push notifications for Android and iOs
- Adds requirePushAuthorization, Android-specific parameters to the configuration.
- Adds compatibility with Android Gradle Plugin 8.
- Used native Sendsay Android SDK to version 0.1.1.
- Used native Sendsay iOS SDK to version 0.1.1.
- Universal links and app links
- Minimum supported Android API level - 24.
- Minimum supported iOs API level - 13.
- Dart SDK version - 2.17.0
- Flutter minimal version - 3.0.0
- Adds documentation.

