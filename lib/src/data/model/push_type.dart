enum PushActionType {
  /// "Open App" action */
  app,

  /// "Deep link" action. In order to open your application from deeplink, extra setup is required.
  deeplink,

  /// "Open web browser" action. Sendsay SDK will automatically open the browser in this case.
  web,
}
