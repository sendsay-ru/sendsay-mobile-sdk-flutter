//
//  NotificationViewController.swift
//  ExampleNotificationContent
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SendsaySDK_Notifications

class NotificationViewController: UIViewController, UNNotificationContentExtension {
  let sendsayService = SendsayNotificationContentService()

  func didReceive(_ notification: UNNotification) {
      sendsayService.didReceive(notification, context: extensionContext, viewController: self)
  }
}
