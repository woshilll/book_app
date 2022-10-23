import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    WoshilllPlugin.register(messenger: controller.binaryMessenger)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let text = try! String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
        WoshilllPlugin.seedBookPath(path: ["name": url.absoluteString, "content": text])
        return super.application(app, open: url, options: options)
    }
}
