import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Setup MethodChannel for focus donations from Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "rct.app/focus", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "donateNSUserActivity", let args = call.arguments as? [String: Any] {
          self?.donateUserActivity(args: args)
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func donateUserActivity(args: [String: Any]) {
    let profile = args["profile"] as? String ?? ""
    let title = args["title"] as? String ?? "Focus"
    let eventId = args["eventId"] as? String ?? UUID().uuidString

    // Create an activity type unique to your app + profile
    let activityType = "com.rct.focus.\(profile)"
    let activity = NSUserActivity(activityType: activityType)
    activity.title = "\(title) — Focus: \(profile)"
    var userInfo: [String: Any] = ["profile": profile, "eventId": eventId]
    if let start = args["startMillis"] as? NSNumber {
      userInfo["startMillis"] = start
    }
    if let end = args["endMillis"] as? NSNumber {
      userInfo["endMillis"] = end
    }
    activity.userInfo = userInfo
    activity.isEligibleForSearch = true
    activity.isEligibleForPrediction = true
    if #available(iOS 12.0, *) {
      activity.persistentIdentifier = NSUserActivityPersistentIdentifier(eventId)
    }
    activity.becomeCurrent()
  }
}
