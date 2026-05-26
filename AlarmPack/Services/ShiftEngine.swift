import Foundation

struct ShiftEngine {
    static func currentWeekType(startDate: Date, weekPattern: [Bool]) -> Int? {
        guard weekPattern.count >= 2 else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let now = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        let weekIndex = (days / 7) % weekPattern.count
        return weekPattern[weekIndex] ? 0 : 1
    }

    static func nextSwitchDate(startDate: Date, weekPattern: [Bool]) -> Date? {
        guard weekPattern.count >= 2 else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let now = calendar.startOfDay(for: Date())
        let daysSinceStart = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        let currentWeek = daysSinceStart / 7
        let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: currentWeek + 1, to: start) ?? start
        return nextWeekStart
    }

    static func shouldAutoSwitch(startDate: Date, weekPattern: [Bool]) -> Bool {
        guard weekPattern.count >= 2 else { return false }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let now = Date()
        let daysSinceStart = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        let daysIntoWeek = daysSinceStart % 7
        return daysIntoWeek == 0 && calendar.component(.hour, from: now) == 0
    }
}
