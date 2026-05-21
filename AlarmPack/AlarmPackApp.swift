import SwiftUI
import SwiftData

@main
struct AlarmPackApp: App {
    @State private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Pack.self, AlarmItem.self, SkipRecord.self, AppSettings.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    PackListView()
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            .onAppear {
                checkOnboardingStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                rescheduleActiveAlarms()
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func checkOnboardingStatus() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<AppSettings>()
        if let settings = try? context.fetch(descriptor).first {
            hasCompletedOnboarding = settings.hasCompletedOnboarding
        }
        let skipManager = SkipManager(modelContext: context)
        skipManager.cleanupExpiredSkips()
    }

    private func rescheduleActiveAlarms() {
        let context = sharedModelContainer.mainContext
        let skipManager = SkipManager(modelContext: context)
        skipManager.cleanupExpiredSkips()

        let descriptor = FetchDescriptor<Pack>(predicate: #Predicate { $0.isActive })
        guard let activePack = try? context.fetch(descriptor).first else { return }
        Task {
            await AlarmScheduler.shared.scheduleAllAlarms(in: activePack)
        }
    }
}
