import Flutter
import UIKit

public class SwiftVozovozAppUpdaterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vozovoz_app_updater", binaryMessenger: registrar.messenger())
    let instance = SwiftVozovozAppUpdaterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
           switch(call.method) {
            case "getPlatformVersion": result("iOS " + UIDevice.current.systemVersion)
            case "getPackageDetail": result(getPackageInfo())
            default:
                result(FlutterMethodNotImplemented)
            }
    }
    
    private func getPackageInfo() -> [String: String]? {
        do {
            return [
                "appName": Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String,
                "packageName": String(Bundle.main.bundleIdentifier ?? ""),
                "version": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String,
                "buildNumber": Bundle.main.infoDictionary!["CFBundleVersion"] as! String,
            ]
        }  catch {
            return nil;
        }
    }
}
