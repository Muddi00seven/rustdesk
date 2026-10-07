import UIKit

@objc class MacPilotSceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  static var isConfigured: Bool {
    Bundle.main.object(forInfoDictionaryKey: "UIApplicationSceneManifest") != nil
  }

  static func prepareLaunchWindow(for appDelegate: AppDelegate) {
    guard isConfigured, appDelegate.window?.rootViewController == nil else { return }
    // Flutter 3.24's plugin registry needs the storyboard controller before registration.
    let launchWindow = UIWindow(frame: UIScreen.main.bounds)
    launchWindow.rootViewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateInitialViewController()
    appDelegate.window = launchWindow
  }

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
          let appDelegate = UIApplication.shared.delegate as? AppDelegate,
          let controller = appDelegate.window?.rootViewController else {
      NSLog("MacPilot could not initialize the Flutter scene window")
      return
    }
    let sceneWindow = UIWindow(windowScene: windowScene)
    sceneWindow.rootViewController = controller
    window = sceneWindow
    appDelegate.window = sceneWindow

    // UIKit puts cold-start URLs in scene options; the pinned uni_links plugin uses launch options.
    var launchOptions: [UIApplication.LaunchOptionsKey: Any] = [:]
    if let context = connectionOptions.urlContexts.first {
      launchOptions[.url] = context.url
      launchOptions[.sourceApplication] = context.options.sourceApplication
    }
    _ = appDelegate.completeMacPilotSceneLaunch(launchOptions)
    sceneWindow.makeKeyAndVisible()
    for activity in connectionOptions.userActivities {
      self.scene(scene, continue: activity)
    }
  }

  private var appDelegate: AppDelegate? {
    UIApplication.shared.delegate as? AppDelegate
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    appDelegate?.applicationDidBecomeActive(UIApplication.shared)
  }

  func sceneWillResignActive(_ scene: UIScene) {
    appDelegate?.applicationWillResignActive(UIApplication.shared)
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    appDelegate?.applicationWillEnterForeground(UIApplication.shared)
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    appDelegate?.applicationDidEnterBackground(UIApplication.shared)
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for context in URLContexts {
      var options: [UIApplication.OpenURLOptionsKey: Any] = [
        .openInPlace: context.options.openInPlace
      ]
      options[.sourceApplication] = context.options.sourceApplication
      options[.annotation] = context.options.annotation
      _ = appDelegate?.application(UIApplication.shared, open: context.url, options: options)
    }
  }

  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    _ = appDelegate?.application(
      UIApplication.shared,
      continue: userActivity,
      restorationHandler: { _ in }
    )
  }
}
