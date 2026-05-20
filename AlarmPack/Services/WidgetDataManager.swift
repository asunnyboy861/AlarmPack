import Foundation
import WidgetKit

@MainActor
final class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let defaults: UserDefaults? = {
        let groupId = "group.com.zzoutuo.AlarmPack.shared"
        return UserDefaults(suiteName: groupId)
    }()

    private init() {}

    func saveActivePack(_ pack: Pack) {
        defaults?.set(pack.id.uuidString, forKey: "activePackId")
        defaults?.set(pack.name, forKey: "activePackName")
        defaults?.set(pack.iconName, forKey: "activePackIcon")
        defaults?.set(pack.colorHex, forKey: "activePackColor")
        defaults?.set(pack.alarms.filter { $0.isEnabled }.count, forKey: "activePackAlarmCount")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func clearActivePack() {
        defaults?.removeObject(forKey: "activePackId")
        defaults?.removeObject(forKey: "activePackName")
        defaults?.removeObject(forKey: "activePackIcon")
        defaults?.removeObject(forKey: "activePackColor")
        defaults?.removeObject(forKey: "activePackAlarmCount")
        WidgetCenter.shared.reloadAllTimelines()
    }

    var activePackName: String {
        defaults?.string(forKey: "activePackName") ?? "No Active Pack"
    }

    var activePackIcon: String {
        defaults?.string(forKey: "activePackIcon") ?? "alarm"
    }

    var activePackColor: String {
        defaults?.string(forKey: "activePackColor") ?? "FF9500"
    }

    var activePackAlarmCount: Int {
        defaults?.integer(forKey: "activePackAlarmCount") ?? 0
    }
}
