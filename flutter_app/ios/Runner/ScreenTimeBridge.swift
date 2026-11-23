import Flutter
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity

@available(iOS 16.0, *)
public class ScreenTimeBridge: NSObject, FlutterPlugin {

    private let store = ManagedSettingsStore(named: .init("com.mizan.store"))
    private let activityCenter = DeviceActivityCenter()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.mizan.wellbeing/shield",
            binaryMessenger: registrar.messenger()
        )
        let instance = ScreenTimeBridge()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestFamilyControls":
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    result(true)
                } catch {
                    result(false)
                }
            }

        case "isScreenTimeAuthorized":
            let isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
            result(isAuthorized)

        case "scheduleSalahLock":
            guard let args = call.arguments as? [String: Any],
                  let timestamp = args["timestamp"] as? Double,
                  let leadMinutes = args["leadMinutes"] as? Int,
                  let prayerName = args["prayerName"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }

            let prayerDate = Date(timeIntervalSince1970: timestamp / 1000.0)
            scheduleSalahInterval(prayerDate: prayerDate, leadMinutes: leadMinutes, prayerName: prayerName)
            result(true)

        case "clearAllShields":
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func scheduleSalahInterval(prayerDate: Date, leadMinutes: Int, prayerName: String) {
        let calendar = Calendar.current
        let startDate = prayerDate.addingTimeInterval(-Double(leadMinutes * 60))
        let endDate = prayerDate.addingTimeInterval(Double(25 * 60))

        let schedule = DeviceActivitySchedule(
            intervalStart: calendar.dateComponents([.hour, .minute], from: startDate),
            intervalEnd: calendar.dateComponents([.hour, .minute], from: endDate),
            repeats: false
        )

        let activityName = DeviceActivityName("salah_lock_\(prayerName)")
        try? activityCenter.startMonitoring(activityName, during: schedule)
    }
}
