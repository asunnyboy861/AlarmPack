import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    func nextOccurrence(ofHour hour: Int, minute: Int) -> Date {
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month, .day], from: self)
        components.hour = hour
        components.minute = minute
        components.second = 0
        let target = cal.date(from: components) ?? self
        if target <= self {
            return cal.date(byAdding: .day, value: 1, to: target) ?? target
        }
        return target
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
