import Foundation
import SwiftData

@Model
final class SkipRecord {
    var id: UUID = UUID()
    var alarmId: UUID = UUID()
    var skipDate: Date = Date()
    var createdAt: Date = Date()

    init(alarmId: UUID, skipDate: Date) {
        self.id = UUID()
        self.alarmId = alarmId
        self.skipDate = skipDate
        self.createdAt = Date()
    }
}
