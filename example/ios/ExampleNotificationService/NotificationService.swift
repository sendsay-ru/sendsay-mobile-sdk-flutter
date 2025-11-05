//
//  NotificationService.swift
//  ExampleNotificationService
//

import UserNotifications
import SendsaySDK_Notifications

class NotificationService: UNNotificationServiceExtension {
  let sendsayService = SendsayNotificationService(
      appGroup: "group.com.sendsay.SendsaySDK"
  )

  override func didReceive(
      _ request: UNNotificationRequest,
      withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
      sendsayService.process(request: request, contentHandler: contentHandler)
  }

  override func serviceExtensionTimeWillExpire() {
      sendsayService.serviceExtensionTimeWillExpire()
  }
}
