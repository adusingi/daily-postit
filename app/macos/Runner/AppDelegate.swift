import Cocoa
import FlutterMacOS
import Sparkle

@main
class AppDelegate: FlutterAppDelegate {
  
  private var updaterController: SPUStandardUpdaterController?
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Initialize Sparkle updater only when configured (disabled in Debug)
    if shouldStartUpdater() {
      updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
      )
    }
    
    // Setup Flutter method channel for update checks
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.dailypostit/updater",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "checkForUpdates":
        self?.updaterController?.checkForUpdates(nil)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func shouldStartUpdater() -> Bool {
    #if DEBUG
    return false
    #else
    let feedURL = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String
    let publicKey = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String

    guard let feedURL, !feedURL.isEmpty,
          let publicKey, !publicKey.isEmpty else {
      return false
    }

    if feedURL == "https://your-domain.com/appcast.xml" || publicKey == "YOUR_PUBLIC_ED_KEY" {
      return false
    }

    return URL(string: feedURL) != nil
    #endif
  }
}
