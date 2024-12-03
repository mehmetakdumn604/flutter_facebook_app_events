import Flutter
import UIKit
import FBSDKCoreKit
// import FBAdSettings

enum Action: String {
    case resetUserId = "reset_user_id"
    case setUserId = "set_user_id"
    case logEvent = "log_event"
    case getAnonymousId = "get_anonymous_id"
    case setAdvertiserTracking = "set_advertiser_tracking"
    case setAutoLogAppEventsEnabled = "set_auto_log_app_events_enabled"
}

public class FlutterFacebookAppeventsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_facebook_appevents", binaryMessenger: registrar.messenger())
        let instance = FlutterFacebookAppeventsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let action = Action(rawValue: call.method) else {
            return
        }
        switch action {
        case .resetUserId:
            AppEvents.shared.userID = nil
            result(nil)
        case .setUserId:
            guard let userID = call.arguments as? String else {
                return
            }
            AppEvents.shared.userID = userID
            result(nil)
        case .getAnonymousId:
            result(AppEvents.shared.anonymousID)
        case .setAdvertiserTracking:
            handleSetAdvertiserTracking(call, result: result)
            break
        case .setAutoLogAppEventsEnabled:
            handleSetAutoLogAppEventsEnabled(call, result: result)
            break
        case .logEvent:
            guard let jsonString = call.arguments as? String else {
                return
            }
            do {
                guard
                    let dict = try JSONSerialization.jsonObject(
                        with: jsonString.data(using: .utf8)!, options: []) as? [AnyHashable: Any]
                else {
                    return
                }
                guard let eventName = dict["event_name"] as? String else {
                    return
                }
                let appEventName = AppEvents.Name(rawValue: eventName)
                if let parameters = dict["parameters"] as? [String: Any] {
                    var converted: [AppEvents.ParameterName : Any] = [:]
                    for key in parameters.keys {
                        let paramName = AppEvents.ParameterName(key)
                        converted[paramName] = parameters[key]
                    }
                    AppEvents.shared.logEvent(appEventName, parameters: converted)
                } else {
                    AppEvents.shared.logEvent(appEventName)
                }
                result(nil)
            } catch {
                result(error)
            }
        }
    }
    private func handleSetAdvertiserTracking(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        // FBAdSettings.setAdvertiserTrackingEnabled(true)
        Settings.shared.isAdvertiserTrackingEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        result(nil)
    }
     private func handleSetAutoLogAppEventsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enabled = call.arguments as! Bool
        Settings.shared.isAutoLogAppEventsEnabled = enabled
        result(nil)
    }
}

extension FlutterFacebookAppeventsPlugin {

    public func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.shared.activateApp()
    }

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions as? [UIApplication.LaunchOptionsKey: Any])
        return false
    }

    public func application(
        _ application: UIApplication, open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(application, open: url, options: options)
        return false
    }

}
