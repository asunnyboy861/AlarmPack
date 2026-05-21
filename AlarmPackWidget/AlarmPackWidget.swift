import WidgetKit
import SwiftUI

struct AlarmPackEntry: TimelineEntry {
    let date: Date
    let packName: String
    let packIcon: String
    let packColor: String
    let alarmCount: Int
    let isActive: Bool
}

struct AlarmPackProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlarmPackEntry {
        AlarmPackEntry(date: Date(), packName: "Work", packIcon: "briefcase", packColor: "FF9500", alarmCount: 3, isActive: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmPackEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlarmPackEntry>) -> Void) {
        let entry = loadEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()))
        completion(timeline)
    }

    private func loadEntry() -> AlarmPackEntry {
        let defaults = UserDefaults(suiteName: "group.com.zzoutuo.AlarmPack.shared")
        let name = defaults?.string(forKey: "activePackName") ?? "No Pack"
        let icon = defaults?.string(forKey: "activePackIcon") ?? "alarm"
        let color = defaults?.string(forKey: "activePackColor") ?? "FF9500"
        let count = defaults?.integer(forKey: "activePackAlarmCount") ?? 0
        let hasActive = defaults?.string(forKey: "activePackId") != nil
        return AlarmPackEntry(date: Date(), packName: name, packIcon: icon, packColor: color, alarmCount: count, isActive: hasActive)
    }
}

struct AlarmPackWidgetEntryView: View {
    let entry: AlarmPackEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(spacing: 8) {
            Image(systemName: entry.packIcon)
                .font(.title2)
                .foregroundStyle(Color(hex: entry.packColor))

            Text(entry.packName)
                .font(.headline)
                .lineLimit(1)

            if entry.isActive {
                Text("\(entry.alarmCount) alarms")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("No active pack")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            Image(systemName: entry.packIcon)
                .font(.title)
                .foregroundStyle(Color(hex: entry.packColor))
                .frame(width: 50, height: 50)
                .background(Color(hex: entry.packColor).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.isActive ? entry.packName : "No Active Pack")
                    .font(.headline)
                if entry.isActive {
                    Text("\(entry.alarmCount) alarms active")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if entry.isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

extension Color {
    nonisolated init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 149, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

@main
struct AlarmPackWidget: Widget {
    let kind: String = "AlarmPackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlarmPackProvider()) { entry in
            AlarmPackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AlarmPack")
        .description("View your active alarm pack and quickly switch packs.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
