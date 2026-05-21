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
}
