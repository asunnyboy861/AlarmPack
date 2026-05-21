import Foundation
import SwiftData

@Observable
@MainActor
final class SkipManager {
    private let modelContext: ModelContext
    private let alarmScheduler = AlarmScheduler.shared

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func skipAlarm(_ alarm: AlarmItem) async {
        guard !alarm.isSkippedToday else { return }
        alarm.isSkippedToday = true
        if alarm.pack?.isActive == true {
            await alarmScheduler.removeAlarm(alarm)
        }
        let tomorrow = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let record = SkipRecord(alarmId: alarm.id, skipDate: tomorrow)
        modelContext.insert(record)
        try? modelContext.save()
    }

    func skipAllTomorrow(in pack: Pack) async {
        for alarm in pack.alarms where alarm.isEnabled {
            await skipAlarm(alarm)
        }
    }

    func unskipAlarm(_ alarm: AlarmItem) async {
        alarm.isSkippedToday = false
        if let pack = alarm.pack, pack.isActive {
            await alarmScheduler.scheduleAlarm(alarm, in: pack)
        }
        let descriptor = FetchDescriptor<SkipRecord>()
        if let records = try? modelContext.fetch(descriptor) {
            let matching = records.filter { $0.alarmId == alarm.id }
            for record in matching {
                modelContext.delete(record)
            }
        }
        try? modelContext.save()
    }

    func cleanupExpiredSkips() {
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        let descriptor = FetchDescriptor<SkipRecord>()
        if let records = try? modelContext.fetch(descriptor) {
            let expired = records.filter { $0.skipDate <= startOfToday }
            let alarmDescriptor = FetchDescriptor<AlarmItem>()
            let allAlarms = (try? modelContext.fetch(alarmDescriptor)) ?? []
            for record in expired {
                if let alarm = allAlarms.first(where: { $0.id == record.alarmId }) {
                    alarm.isSkippedToday = false
                    if alarm.isEnabled, alarm.pack?.isActive == true {
                        Task {
                            await AlarmScheduler.shared.scheduleAlarm(alarm, in: alarm.pack!)
                        }
                    }
                }
                modelContext.delete(record)
            }
        }
        try? modelContext.save()
    }
}
