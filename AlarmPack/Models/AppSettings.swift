import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID = UUID()
    var defaultSnooze: Int = 9
    var hapticEnabled: Bool = true
    var isPro: Bool = false
    var hasCompletedOnboarding: Bool = false
    var activePackId: UUID = UUID()

    init() {
        self.id = UUID()
        self.defaultSnooze = 9
        self.hapticEnabled = true
        self.isPro = false
        self.hasCompletedOnboarding = false
        self.activePackId = UUID()
    }
}
