import SwiftUI

struct PackCardView: View {
    let pack: Pack
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: pack.iconName)
                .font(.title2)
                .foregroundStyle(Color(hex: pack.colorHex))
                .frame(width: 44, height: 44)
                .background(Color(hex: pack.colorHex).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pack.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if pack.isActive {
                        Text("Active")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: pack.colorHex))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 12) {
                    Label("\(pack.alarms.count) alarms", systemImage: "alarm")
                    if let firstTime = pack.firstAlarmTime {
                        Label(firstTime, systemImage: "clock")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { pack.isActive },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .tint(Color(hex: pack.colorHex))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(pack.isActive ? Color(hex: pack.colorHex).opacity(0.08) : Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
        .contentShape(Rectangle())
    }
}
