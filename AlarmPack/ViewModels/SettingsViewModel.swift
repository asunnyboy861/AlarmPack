import Foundation
import SwiftData

@Observable
@MainActor
final class SettingsViewModel {
    var defaultSnooze: Int = 9
    var hapticEnabled: Bool = true
    var isPro: Bool = false

    private var modelContext: ModelContext
    private var settings: AppSettings?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }

    func loadSettings() {
        let descriptor = FetchDescriptor<AppSettings>()
        settings = (try? modelContext.fetch(descriptor).first) ?? {
            let s = AppSettings()
            modelContext.insert(s)
            try? modelContext.save()
            return s
        }()
        defaultSnooze = settings?.defaultSnooze ?? 9
        hapticEnabled = settings?.hapticEnabled ?? true
        isPro = StoreKitService.shared.isPro
    }

    func updateDefaultSnooze(_ value: Int) {
        defaultSnooze = value
        settings?.defaultSnooze = value
        try? modelContext.save()
    }

    func updateHapticEnabled(_ value: Bool) {
        hapticEnabled = value
        settings?.hapticEnabled = value
        try? modelContext.save()
    }

    func restorePurchases() async {
        await StoreKitService.shared.restorePurchases()
        isPro = StoreKitService.shared.isPro
    }
}
