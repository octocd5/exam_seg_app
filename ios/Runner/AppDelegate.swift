import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Dynamically register / ensure Home Screen Quick Action shortcut is created
    setupExitShortcut(application)

    // Handle MethodChannel for Blocker and Shortcut actions
    if let controller = window?.rootViewController as? FlutterViewController {
      setupMethodChannel(controller: controller, application: application)
    }

    // Check if launched directly from the exit shortcut
    if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem,
       isExitShortcut(shortcutItem) {
      performImmediateExit()
      return false
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle Home Screen Quick Action while app is in background or running
  override func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    if isExitShortcut(shortcutItem) {
      performImmediateExit()
      completionHandler(true)
      return
    }
    completionHandler(false)
  }

  // Handle URL scheme bubble://exit or bubble://shortcut-exit
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "bubble" && (url.host == "exit" || url.path.contains("exit")) {
      performImmediateExit()
      return true
    }
    return super.application(app, open: url, options: options)
  }

  private func setupMethodChannel(controller: FlutterViewController, application: UIApplication) {
    let blockerChannel = FlutterMethodChannel(
      name: "com.example.exam_seg_app/blocker",
      binaryMessenger: controller.binaryMessenger
    )

    blockerChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "requestPermissions":
        result(true)
      case "createShortcut":
        self?.setupExitShortcut(application)
        result(true)
      case "exitApp":
        self?.performImmediateExit()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }

  private func setupExitShortcut(_ application: UIApplication) {
    let exitShortcut = UIMutableApplicationShortcutItem(
      type: "com.example.examSegApp.exitShortcut",
      localizedTitle: "Exit Bubble",
      localizedSubtitle: "Detects and immediately exits the app",
      icon: UIApplicationShortcutIcon(type: .prohibit),
      userInfo: ["action": "immediate_exit"]
    )
    application.shortcutItems = [exitShortcut]
  }

  private func isExitShortcut(_ item: UIApplicationShortcutItem) -> Bool {
    return item.type == "com.example.examSegApp.exitShortcut" ||
           (item.userInfo?["action"] as? String) == "immediate_exit"
  }

  private func performImmediateExit() {
    UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      exit(0)
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
