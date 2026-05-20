import Foundation
import SwiftData

@Observable
@MainActor
final class OnboardingViewModel {
    var selectedTemplates: Set<String> = []
    var currentPage = 0

    private var modelContext: ModelContext

    let templates: [(name: String, icon: String, color: String, alarms: [(hour: Int, minute: Int, label: String)])] = [
        ("Work", "briefcase", "FF9500", [(6,30,"Wake Up"), (7,0,"Leave Home"), (7,30,"Arrive Office")]),
        ("School", "book", "5856D6", [(7,0,"Wake Up"), (7,30,"First Class"), (12,0,"Lunch")]),
        ("Gym", "figure.run", "30D158", [(5,30,"Early Workout"), (6,30,"Post-Workout"), (17,0,"Evening Session")]),
        ("Weekend", "sun.max", "FF375F", [(9,0,"Sleep In"), (10,0,"Brunch"), (14,0,"Activity")]),
        ("Night Shift", "moon.stars", "0A84FF", [(18,0,"Pre-Shift"), (22,0,"Break"), (6,0,"End Shift")])
    ]

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func toggleTemplate(_ name: String) {
        if selectedTemplates.contains(name) {
            selectedTemplates.remove(name)
        } else {
            selectedTemplates.insert(name)
        }
    }

    func completeOnboarding() -> Bool {
        let packManager = PackManager(modelContext: modelContext)
        var firstPack: Pack?
        for template in templates where selectedTemplates.contains(template.name) {
            let pack = packManager.createPack(name: template.name, iconName: template.icon, colorHex: template.color)
            if firstPack == nil {
                firstPack = pack
            }
            for alarmData in template.alarms {
                let alarm = AlarmItem(hour: alarmData.hour, minute: alarmData.minute, label: alarmData.label)
                alarm.pack = pack
                modelContext.insert(alarm)
            }
        }

        if let first = firstPack {
            Task { await packManager.togglePack(first) }
        }

        let descriptor = FetchDescriptor<AppSettings>()
        if let settings = try? modelContext.fetch(descriptor).first {
            settings.hasCompletedOnboarding = true
        } else {
            let settings = AppSettings()
            settings.hasCompletedOnboarding = true
            modelContext.insert(settings)
        }
        try? modelContext.save()
        return true
    }
}
