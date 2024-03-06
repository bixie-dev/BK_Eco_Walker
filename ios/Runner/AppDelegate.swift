import UIKit
import Flutter
import GoogleMaps
import UserNotifications

@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    GMSServices.provideAPIKey("AIzaSyC8a5fu0KEqJYgZ-XAOZSkG7fNo03VHg04")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
