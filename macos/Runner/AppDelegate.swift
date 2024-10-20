import Cocoa
import FlutterMacOS

@main
class AppDelegate: NSObject, NSApplicationDelegate{
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  func application(_ application: NSApplication, openFiles filenames: [String]) {
    for filename in filenames {
      let flutterViewController = NSApplication.shared.windows.first?.contentViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: "fileChannel", binaryMessenger: flutterViewController.engine.binaryMessenger)
      channel.invokeMethod("loadFile", arguments: filename)
    }
  }
}
