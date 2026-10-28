import Flutter
import UIKit

/// Implements the example channel using the engine's lifecycle registration.
final class ExampleNativeChannel: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel
    private let tracker = APNsTokenTracker {
        UIApplication.shared.registerForRemoteNotifications()
    }

    private init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.sendsay.example/native",
            binaryMessenger: registrar.messenger()
        )
        let instance = ExampleNativeChannel(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.publish(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getResources":
            result([String: Any]())
        case "getPushToken":
            tracker.getToken { outcome in
                switch outcome {
                case .success(let token):
                    result(token)
                case .failure(let error):
                    let code = error as? APNsTokenTracker.Failure == .timedOut
                        ? "token_timeout" : "token_unavailable"
                    result(FlutterError(
                        code: code,
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        tracker.didRegister(token: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        tracker.didFail(error: error)
    }

    func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel.setMethodCallHandler(nil)
        tracker.cancel()
    }
}
