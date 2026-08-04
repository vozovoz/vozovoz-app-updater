import Flutter
import UIKit

public class VozovozAppUpdaterPlugin: NSObject, FlutterPlugin {
  private static let channelName = "vozovoz_app_updater"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = VozovozAppUpdaterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getPackageDetail":
      result(packageDetail())
    case "getDeviceInfo":
      result(deviceInfo())
    default:
      // checkForUpdate / performImmediateUpdate / startFlexibleUpdate /
      // completeFlexibleUpdate — только Android (Google Play / RuStore).
      result(FlutterMethodNotImplemented)
    }
  }

  private func packageDetail() -> [String: String] {
    let info = Bundle.main.infoDictionary ?? [:]
    // CFBundleDisplayName есть не у всех приложений, поэтому откатываемся на
    // CFBundleName. Форсированный каст здесь ронял приложение.
    let appName = (info["CFBundleDisplayName"] as? String)
      ?? (info["CFBundleName"] as? String)
      ?? ""

    return [
      "appName": appName,
      "packageName": Bundle.main.bundleIdentifier ?? "",
      "version": (info["CFBundleShortVersionString"] as? String) ?? "0.0.0",
      "buildNumber": (info["CFBundleVersion"] as? String) ?? "",
    ]
  }

  private func deviceInfo() -> [String: Any] {
    let device = UIDevice.current
    return [
      "manufacturer": "Apple",
      "brand": "Apple",
      "model": Self.machineIdentifier(),
      "device": device.model,
      "systemVersion": device.systemVersion,
      "systemName": device.systemName,
    ]
  }

  /// Аппаратный идентификатор вида `iPhone14,5`. `UIDevice.model` возвращает
  /// только общее «iPhone», чего недостаточно для аналитики.
  private static func machineIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return withUnsafeBytes(of: &systemInfo.machine) { rawBuffer in
      let bytes = rawBuffer.prefix(while: { $0 != 0 })
      return String(decoding: bytes, as: UTF8.self)
    }
  }
}
