import Foundation
import SwiftData
import SwiftUI
import UserNotifications
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
            return
        }
        #endif
        await scheduleWithLocalNotification(alarm, in: pack)
    }

    func removeAlarm(_ alarm: AlarmItem) async {
        #if canImport(AlarmKit)
        if #available(iOS 26, *) {
            await removeFromAlarmKit(alarm)
            return
        }
        #endif
        removeFromLocalNotification(alarm)
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

    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    private func scheduleWithLocalNotification(_ alarm: AlarmItem, in pack: Pack) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? pack.name : alarm.label
        content.body = "Alarm - \(alarm.timeString)"
        content.sound = .default
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmId": alarm.id.uuidString]

        if alarm.isRepeating {
            let days = alarm.repeatDaysArray.sorted()
            for day in days {
                let weekday = day + 1
                var dateComponents = DateComponents()
                dateComponents.hour = alarm.hour
                dateComponents.minute = alarm.minute
                dateComponents.weekday = weekday
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "\(alarm.id.uuidString)-\(day)", content: content, trigger: trigger)
                do {
                    try await center.add(request)
                } catch {
                    print("Local notification schedule error: \(error)")
                }
            }
        } else {
            var dateComponents = DateComponents()
            dateComponents.hour = alarm.hour
            dateComponents.minute = alarm.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
            do {
                try await center.add(request)
            } catch {
                print("Local notification schedule error: \(error)")
            }
        }
    }

    private func removeFromLocalNotification(_ alarm: AlarmItem) {
        let center = UNUserNotificationCenter.current()
        if alarm.isRepeating {
            let days = alarm.repeatDaysArray
            let ids = days.map { "\(alarm.id.uuidString)-\($0)" }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        } else {
            center.removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
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
