import '../model/configuration.dart';
import '../util/object.dart';
import 'http_log_level.dart';
import 'notification_importance.dart';
import 'project.dart';
import 'token_frequency.dart';

abstract class SendsayConfigurationEncoder {
  static SendsayConfiguration decode(Map<String, dynamic> data) {
    return SendsayConfiguration(
      projectToken: data.getRequired('projectToken'),
      authorizationToken: data.getRequired('authorizationToken'),
      baseUrl: data.getOptional('baseUrl'),
      projectMapping: data
          .getOptional<Map<String, dynamic>>('projectMapping')
          ?.let(SendsayProjectMappingEncoder.decode),
      defaultProperties: data
          .getOptional<Map<String, dynamic>>('defaultProperties')
          ?.cast<String, Object>(),
      flushMaxRetries: data.getOptional<num>('flushMaxRetries')?.toInt(),
      sessionTimeout: data.getOptional('sessionTimeout'),
      automaticSessionTracking: data.getOptional('automaticSessionTracking'),
      pushTokenTrackingFrequency: data
          .getOptional<String>('pushTokenTrackingFrequency')
          ?.let(TokenFrequencyEncoder.decode),
      requirePushAuthorization: data.getOptional('requirePushAuthorization'),
      allowDefaultCustomerProperties: data.getOptional('allowDefaultCustomerProperties'),
      advancedAuthEnabled: data.getOptional('advancedAuthEnabled'),
      android: data
          .getOptional<Map<String, dynamic>>('android')
          ?.let(AndroidSendsayConfigurationEncoder.decode),
      ios: data
          .getOptional<Map<String, dynamic>>('ios')
          ?.let(IOSSendsayConfigurationEncoder.decode),
      inAppContentBlockPlaceholdersAutoLoad: data
          .getOptional<List>('inAppContentBlockPlaceholdersAutoLoad')
          ?.map((it) => it.toString())
          .toList(growable: false),
      manualSessionAutoClose: data.getOptional('manualSessionAutoClose'),
    );
  }

  static Map<String, dynamic> encode(SendsayConfiguration config) {
    return {
      'projectToken': config.projectToken,
      'authorizationToken': config.authorizationToken,
      'baseUrl': config.baseUrl,
      'projectMapping':
          config.projectMapping?.let(SendsayProjectMappingEncoder.encode),
      'defaultProperties': config.defaultProperties,
      'flushMaxRetries': config.flushMaxRetries?.toDouble(),
      'sessionTimeout': config.sessionTimeout,
      'automaticSessionTracking': config.automaticSessionTracking,
      'allowDefaultCustomerProperties': config.allowDefaultCustomerProperties,
      'advancedAuthEnabled': config.advancedAuthEnabled,
      'pushTokenTrackingFrequency':
          config.pushTokenTrackingFrequency?.let(TokenFrequencyEncoder.encode),
      'requirePushAuthorization': config.requirePushAuthorization,
      'android': config.android?.let(AndroidSendsayConfigurationEncoder.encode),
      'ios': config.ios?.let(IOSSendsayConfigurationEncoder.encode),
      'inAppContentBlockPlaceholdersAutoLoad': config.inAppContentBlockPlaceholdersAutoLoad,
      'manualSessionAutoClose' : config.manualSessionAutoClose,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class AndroidSendsayConfigurationEncoder {
  static AndroidSendsayConfiguration decode(Map<String, dynamic> data) {
    return AndroidSendsayConfiguration(
      automaticPushNotifications:
          data.getOptional('automaticPushNotifications'),
      pushIcon: data.getOptional<num>('pushIcon')?.toInt(),
      pushAccentColor: data.getOptional<num>('pushAccentColor')?.toInt(),
      pushChannelName: data.getOptional('pushChannelName'),
      pushChannelDescription: data.getOptional('pushChannelDescription'),
      pushChannelId: data.getOptional('pushChannelId'),
      pushNotificationImportance: data
          .getOptional<String>('pushNotificationImportance')
          ?.let(PushNotificationImportanceEncoder.decode),
      httpLoggingLevel: data
          .getOptional<String>('httpLoggingLevel')
          ?.let(HttpLoggingLevelEncoder.decode),
      appInboxDetailImageInset: data.getOptional<num>('appInboxDetailImageInset')?.toInt(),
      allowWebViewCookies: data.getOptional('allowWebViewCookies'),
    );
  }

  static Map<String, dynamic> encode(AndroidSendsayConfiguration config) {
    return {
      'automaticPushNotifications': config.automaticPushNotifications,
      'pushIcon': config.pushIcon?.toDouble(),
      'pushAccentColor': config.pushAccentColor?.toDouble(),
      'pushChannelName': config.pushChannelName,
      'pushChannelDescription': config.pushChannelDescription,
      'pushChannelId': config.pushChannelId,
      'pushNotificationImportance': config.pushNotificationImportance
          ?.let(PushNotificationImportanceEncoder.encode),
      'httpLoggingLevel':
          config.httpLoggingLevel?.let(HttpLoggingLevelEncoder.encode),
      'appInboxDetailImageInset': config.appInboxDetailImageInset?.toDouble(),
      'allowWebViewCookies': config.allowWebViewCookies,
    };
  }
}

abstract class IOSSendsayConfigurationEncoder {
  static IOSSendsayConfiguration decode(Map<String, dynamic> data) {
    return IOSSendsayConfiguration(
      requirePushAuthorization: data.getOptional('requirePushAuthorization'),
      appGroup: data.getOptional('appGroup'),
    );
  }

  static Map<String, dynamic> encode(IOSSendsayConfiguration config) {
    return {
      'requirePushAuthorization': config.requirePushAuthorization,
      'appGroup': config.appGroup,
    };
  }
}
