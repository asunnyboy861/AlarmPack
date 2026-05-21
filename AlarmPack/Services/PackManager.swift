import Foundation
import SwiftData
import UIKit

@Observable
@MainActor
final class PackManager {
    private let modelContext: ModelContext
    private let alarmScheduler = AlarmScheduler.shared

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func togglePack(_ pack: Pack) async {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()

        let descriptor = FetchDescriptor<Pack>(predicate: #Predicate { $0.isActive })
        if let activePacks = try? modelContext.fetch(descriptor) {
            for activePack in activePacks {
                activePack.isActive = false
                await alarmScheduler.removeAllAlarms(in: activePack)
            }
        }

        let skipManager = SkipManager(modelContext: modelContext)
        skipManager.cleanupExpiredSkips()

        pack.isActive = true
        await alarmScheduler.scheduleAllAlarms(in: pack)

        WidgetDataManager.shared.saveActivePack(pack)

        try? modelContext.save()
    }

    func deactivatePack(_ pack: Pack) async {
        pack.isActive = false
        await alarmScheduler.removeAllAlarms(in: pack)
        WidgetDataManager.shared.clearActivePack()
        try? modelContext.save()
    }

    func createPack(name: String, iconName: String, colorHex: String, scheduleType: Int = 0) -> Pack {
        let descriptor = FetchDescriptor<Pack>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        let pack = Pack(name: name, iconName: iconName, colorHex: colorHex, sortOrder: count)
        modelContext.insert(pack)
        try? modelContext.save()
        return pack
    }

    func updatePack(_ pack: Pack, name: String, iconName: String, colorHex: String, scheduleType: Int) {
        pack.name = name
        pack.iconName = iconName
        pack.colorHex = colorHex
        pack.scheduleType = scheduleType
        try? modelContext.save()
    }

    func deletePack(_ pack: Pack) async {
        await alarmScheduler.removeAllAlarms(in: pack)
        modelContext.delete(pack)
        try? modelContext.save()
    }

    func canCreatePack(isPro: Bool) -> Bool {
        let descriptor = FetchDescriptor<Pack>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return isPro || count < 2
    }

    func canAddAlarm(to pack: Pack, isPro: Bool) -> Bool {
        return isPro || pack.alarms.count < 3
    }
}
