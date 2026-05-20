import Foundation
import SwiftData

@Model
final class Pack {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = "alarm"
    var colorHex: String = "FF9500"
    var sortOrder: Int = 0
    var isActive: Bool = false
    var scheduleType: Int = 0
    var weekPattern: Data = Data()
    var scheduleStartDate: Date = Date()
    var packAId: UUID = UUID()
    var packBId: UUID = UUID()
    var createdAt: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \AlarmItem.pack)
    var alarms: [AlarmItem] = []

    init(name: String, iconName: String = "alarm", colorHex: String = "FF9500", sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isActive = false
        self.scheduleType = 0
        self.weekPattern = Data()
        self.scheduleStartDate = Date()
        self.packAId = UUID()
        self.packBId = UUID()
        self.createdAt = Date()
        self.alarms = []
    }

    var firstAlarmTime: String? {
        let enabled = alarms.filter { $0.isEnabled }.sorted { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
        guard let first = enabled.first else { return nil }
        return String(format: "%d:%02d %@", first.hour > 11 ? first.hour - (first.hour > 12 ? 12 : 0) : first.hour, first.minute, first.hour >= 12 ? "PM" : "AM")
    }

    var enabledAlarmCount: Int {
        alarms.filter { $0.isEnabled }.count
    }
}
