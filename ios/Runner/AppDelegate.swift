import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Maps API Key
    GMSServices.provideAPIKey("AIzaSyD8XMlzAxevE5B2v1x315eQtZBbhF-6cL8")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
