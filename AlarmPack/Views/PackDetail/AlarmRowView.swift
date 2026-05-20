import SwiftUI

struct AlarmRowView: View {
    let alarm: AlarmItem
    let isPro: Bool
    let onToggle: () -> Void
    let onSkip: () -> Void
    let onUnskip: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(alarm.isEnabled ? .primary : .secondary)

                HStack(spacing: 6) {
                    if !alarm.label.isEmpty {
                        Text(alarm.label)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text(alarm.repeatDaysString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                if alarm.isSkippedToday {
                    HStack(spacing: 4) {
                        Image(systemName: "moonrise.fill")
                            .font(.caption2)
                        Text("Skipped")
                            .font(.caption2)
                    }
                    .foregroundStyle(.orange)
                }
            }

            Spacer()

            VStack(spacing: 8) {
                Toggle("", isOn: Binding(get: { alarm.isEnabled }, set: { _ in onToggle() }))
                    .labelsHidden()
                    .tint(.orange)

                if alarm.isEnabled && !alarm.isSkippedToday && isPro {
                    Button {
                        onSkip()
                    } label: {
                        Image(systemName: "moonrise")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                }

                if alarm.isSkippedToday {
                    Button {
                        onUnskip()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
