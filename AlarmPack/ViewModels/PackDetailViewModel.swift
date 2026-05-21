import Foundation
import SwiftData

@Observable
@MainActor
final class PackDetailViewModel {
    var pack: Pack
    var showPaywall = false
    var showAddAlarm = false
    var showSkipAllConfirmation = false

    private var modelContext: ModelContext
    private var skipManager: SkipManager
    private var packManager: PackManager

    init(pack: Pack, modelContext: ModelContext) {
        self.pack = pack
        self.modelContext = modelContext
        self.skipManager = SkipManager(modelContext: modelContext)
        self.packManager = PackManager(modelContext: modelContext)
    }

    var alarms: [AlarmItem] {
        pack.alarms.sorted { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
    }

    func refreshPack() {
        try? modelContext.save()
    }

    func toggleAlarm(_ alarm: AlarmItem) async {
        alarm.isEnabled.toggle()
        if alarm.isEnabled {
            if pack.isActive {
                await AlarmScheduler.shared.scheduleAlarm(alarm, in: pack)
            }
        } else {
            await AlarmScheduler.shared.removeAlarm(alarm)
        }
        try? modelContext.save()
    }

    func skipAlarm(_ alarm: AlarmItem) async {
        guard StoreKitService.shared.isPro else {
            showPaywall = true
            return
        }
        await skipManager.skipAlarm(alarm)
    }

    func unskipAlarm(_ alarm: AlarmItem) async {
        await skipManager.unskipAlarm(alarm)
    }

    func skipAllTomorrow() async {
        guard StoreKitService.shared.isPro else {
            showPaywall = true
            return
        }
        await skipManager.skipAllTomorrow(in: pack)
    }

    func deleteAlarm(_ alarm: AlarmItem) async {
        await AlarmScheduler.shared.removeAlarm(alarm)
        modelContext.delete(alarm)
        try? modelContext.save()
    }

    func canAddAlarm() -> Bool {
        packManager.canAddAlarm(to: pack, isPro: StoreKitService.shared.isPro)
    }

    func showAddAlarmOrPaywall() {
        if canAddAlarm() {
            showAddAlarm = true
        } else {
            showPaywall = true
        }
    }
}
