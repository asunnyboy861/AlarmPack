import Foundation
import SwiftData

@Observable
@MainActor
final class AlarmViewModel {
    var hour: Int = 7
    var minute: Int = 0
    var label: String = ""
    var repeatDays: Set<Int> = []
    var snoozeMinutes: Int = 9
    var soundName: String = "Default"

    private var modelContext: ModelContext
    private var pack: Pack
    private var existingAlarm: AlarmItem?

    init(pack: Pack, modelContext: ModelContext, alarm: AlarmItem? = nil) {
        self.pack = pack
        self.modelContext = modelContext
        self.existingAlarm = alarm
        if let alarm = alarm {
            self.hour = alarm.hour
            self.minute = alarm.minute
            self.label = alarm.label
            self.repeatDays = Set(alarm.repeatDaysArray)
            self.snoozeMinutes = alarm.snoozeMinutes
            self.soundName = alarm.soundName
        }
    }

    func deleteAlarm() async {
        guard let existing = existingAlarm else { return }
        await AlarmScheduler.shared.removeAlarm(existing)
        modelContext.delete(existing)
        try? modelContext.save()
    }

    func saveAlarm() async -> Bool {
        if let existing = existingAlarm {
            if pack.isActive {
                await AlarmScheduler.shared.removeAlarm(existing)
            }
            existing.hour = hour
            existing.minute = minute
            existing.label = label
            existing.repeatDaysArray = Array(repeatDays).sorted()
            existing.snoozeMinutes = snoozeMinutes
            existing.soundName = soundName
            if pack.isActive && existing.isEnabled && !existing.isSkippedToday {
                await AlarmScheduler.shared.scheduleAlarm(existing, in: pack)
            }
        } else {
            let alarm = AlarmItem(hour: hour, minute: minute, label: label, repeatDays: Array(repeatDays).sorted(), snoozeMinutes: snoozeMinutes, soundName: soundName)
            alarm.pack = pack
            modelContext.insert(alarm)
            if pack.isActive {
                await AlarmScheduler.shared.scheduleAlarm(alarm, in: pack)
            }
        }
        try? modelContext.save()
        return true
    }
}
