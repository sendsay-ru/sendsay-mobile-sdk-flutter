/// Notification resources resolved by Android for this flavor and locale.
typedef AndroidNotificationResources = ({
  String channelId,
  String channelName,
  String channelDescription,
  int icon,
});

/// Native resource groups; platform-specific groups are optional.
typedef ExampleResources = ({
  AndroidNotificationResources? androidNotifications,
});

/// Native capabilities of the example, independent of the channel transport.
abstract interface class ExampleNativeApi {
  /// Loads native configuration resources.
  Future<ExampleResources> getResources();

  /// Retrieves a token from the current push provider.
  ///
  /// Supports Android providers and APNs on iOS. The APNs registration
  /// callback also reaches the SDK through its existing AppDelegate.
  Future<String> getPushToken();
}
