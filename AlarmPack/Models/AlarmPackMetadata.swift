import Foundation
#if canImport(AlarmKit)
import AlarmKit

nonisolated struct AlarmPackMetadata: AlarmMetadata {
    var iconName: String
    var title: String
    var createdAt: Date = Date()
}
#endif
