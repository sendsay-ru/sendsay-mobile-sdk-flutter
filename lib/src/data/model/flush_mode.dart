enum FlushMode {
  /// Events are flushed to Sendsay backend periodically based on flush period
  period,

  /// Events are flushed to Sendsay backend when application is closed
  appClose,

  /// Events are flushed to Sendsay when flushData() is manually called by the developer
  manual,

  /// Events are flushed to Sendsay backend immediately when they are tracked
  immediate,
}
