import Foundation
import SwiftData

@Model
final class AlarmItem {
    var id: UUID = UUID()
    var hour: Int = 7
    var minute: Int = 0
    var label: String = ""
    var repeatDays: Data = Data()
    var snoozeMinutes: Int = 9
    var isEnabled: Bool = true
    var soundName: String = "Default"
    var isSkippedToday: Bool = false
    var createdAt: Date = Date()
    var pack: Pack?

    init(hour: Int = 7, minute: Int = 0, label: String = "", repeatDays: [Int] = [], snoozeMinutes: Int = 9, soundName: String = "Default") {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.label = label
        self.repeatDays = (try? JSONEncoder().encode(repeatDays)) ?? Data()
        self.snoozeMinutes = snoozeMinutes
        self.isEnabled = true
        self.soundName = soundName
        self.isSkippedToday = false
        self.createdAt = Date()
        self.pack = nil
    }

    var repeatDaysArray: [Int] {
        get {
            (try? JSONDecoder().decode([Int].self, from: repeatDays)) ?? []
        }
        set {
            repeatDays = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    var isRepeating: Bool {
        !repeatDaysArray.isEmpty
    }

    var timeString: String {
        let h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let period = hour >= 12 ? "PM" : "AM"
        return String(format: "%d:%02d %@", h, minute, period)
    }

    var repeatDaysString: String {
        let days = repeatDaysArray.sorted()
        if days.isEmpty { return "Once" }
        if days == [1,2,3,4,5] { return "Weekdays" }
        if days == [0,6] { return "Weekends" }
        if days == [0,1,2,3,4,5,6] { return "Every Day" }
        let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return days.map { names[$0] }.joined(separator: ", ")
    }
}
