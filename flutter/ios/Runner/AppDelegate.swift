import UIKit
import Flutter
import GameController

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    MacPilotSceneDelegate.prepareLaunchWindow(for: self)
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "macpilot/input", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        if call.method == "hardwareKeyboardConnected" {
          if #available(iOS 14.0, *) {
            result(GCKeyboard.coalesced != nil)
          } else {
            result(false)
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    dummyMethodToEnforceBundling();
    if MacPilotSceneDelegate.isConfigured {
      return true
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func completeMacPilotSceneLaunch(_ options: [UIApplication.LaunchOptionsKey: Any]) -> Bool {
    return super.application(UIApplication.shared, didFinishLaunchingWithOptions: options)
  }
    
  public func dummyMethodToEnforceBundling() {
      dummy_method_to_enforce_bundling();
    session_get_rgba(nil, 0);
  }
}
