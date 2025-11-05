import Foundation
import Flutter
import sendsay

@main
@objc class AppDelegate: SendsayFlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

