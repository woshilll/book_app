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
        do {
            let text = try String(contentsOfFile: url.path, encoding: .utf8)
            WoshilllPlugin.seedBookPath(path: ["name": url.absoluteString, "content": text])
        } catch {
            do {
                let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                let text = try NSString(contentsOfFile: url.path, encoding: enc) as String
                WoshilllPlugin.seedBookPath(path: ["name": url.absoluteString, "content": text])
            } catch {}
        }
        return super.application(app, open: url, options: options)
    }
}
