import Foundation
import SwiftData
import SwiftUI
#if canImport(AlarmKit)
import AlarmKit
import ActivityKit
#endif

actor AlarmScheduler {
    static let shared = AlarmScheduler()

    func scheduleAlarm(_ alarm: AlarmItem, in pack: Pack) async {
        guard alarm.isEnabled, !alarm.isSkippedToday else { return }
        #if canImport(AlarmKit)
        if #available(iOS 26, *) {
            await scheduleWithAlarmKit(alarm, in: pack)
        }
        #endif
    }

    func removeAlarm(_ alarm: AlarmItem) async {
        #if canImport(AlarmKit)
        if #available(iOS 26, *) {
            await removeFromAlarmKit(alarm)
        }
        #endif
    }

    func scheduleAllAlarms(in pack: Pack) async {
        for alarm in pack.alarms where alarm.isEnabled && !alarm.isSkippedToday {
            await scheduleAlarm(alarm, in: pack)
        }
    }

    func removeAllAlarms(in pack: Pack) async {
        for alarm in pack.alarms {
            await removeAlarm(alarm)
        }
    }

    #if canImport(AlarmKit)
    @available(iOS 26, *)
    private func scheduleWithAlarmKit(_ alarm: AlarmItem, in pack: Pack) async {
        do {
            let alarmManager = AlarmManager.shared
            let alarmID = alarm.id
            let schedule = try createSchedule(for: alarm)
            let title = alarm.label.isEmpty ? pack.name : alarm.label
            let stopButton = AlarmButton(text: "Stop", textColor: .white, systemImageName: "xmark")
            let alert = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: title),
                stopButton: stopButton,
                secondaryButton: nil,
                secondaryButtonBehavior: nil
            )
            let presentation = AlarmPresentation(alert: alert)
            let metadata = AlarmPackMetadata(iconName: pack.iconName, title: title)
            let tintColor = Color(hex: pack.colorHex)
            let attributes = AlarmAttributes<AlarmPackMetadata>(
                presentation: presentation,
                metadata: metadata,
                tintColor: tintColor
            )
            let configuration = AlarmManager.AlarmConfiguration<AlarmPackMetadata>.alarm(
                schedule: schedule,
                attributes: attributes,
                stopIntent: nil,
                secondaryIntent: nil,
                sound: .default
            )
            _ = try await alarmManager.schedule(id: alarmID, configuration: configuration)
        } catch {
            print("AlarmKit schedule error: \(error)")
        }
    }

    @available(iOS 26, *)
    private func createSchedule(for alarm: AlarmItem) throws -> Alarm.Schedule {
        let time = Alarm.Schedule.Relative.Time(hour: alarm.hour, minute: alarm.minute)
        let repeats: Set<Locale.Weekday>
        if alarm.isRepeating {
            repeats = Set(alarm.repeatDaysArray.compactMap { day -> Locale.Weekday? in
                let weekdayMap: [Int: Locale.Weekday] = [
                    0: .sunday, 1: .monday, 2: .tuesday, 3: .wednesday,
                    4: .thursday, 5: .friday, 6: .saturday
                ]
                return weekdayMap[day]
            })
        } else {
            repeats = []
        }
        let relativeSchedule = Alarm.Schedule.Relative(
            time: time,
            repeats: repeats.isEmpty ? .never : .weekly(Array(repeats))
        )
        return .relative(relativeSchedule)
    }

    @available(iOS 26, *)
    private func removeFromAlarmKit(_ alarm: AlarmItem) async {
        do {
            let alarmManager = AlarmManager.shared
            try alarmManager.cancel(id: alarm.id)
        } catch {
            print("AlarmKit cancel error: \(error)")
        }
    }
    #endif
}
