import SwiftUI

struct AddPackView: View {
    let packManager: PackManager
    let onDismiss: () -> Void

    @State private var name = ""
    @State private var selectedIcon = "alarm"
    @State private var selectedColor = "FF9500"
    @State private var scheduleType = 0
    @Environment(\.dismiss) private var dismiss

    private let icons = ["alarm", "briefcase", "book", "figure.run", "sun.max", "moon.stars", "star", "heart", "leaf", "flame", "snowflake", "drop"]
    private let colors = ["FF9500", "FF375F", "5856D6", "0A84FF", "30D158", "FFD60A", "FF6B6B", "64D2FF", "BF5AF2", "FF9F0A"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Pack Name") {
                    TextField("e.g. Work, School, Gym", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedIcon == icon ? Color(hex: selectedColor) : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .scaleEffect(selectedColor == color ? 1.15 : 1.0)
                                .onTapGesture { selectedColor = color }
                        }
                    }
                    .padding(.vertical, 4)
                }

                if StoreKitService.shared.isPro {
                    Section("Schedule Type") {
                        Picker("Schedule", selection: $scheduleType) {
                            Text("Manual").tag(0)
                            Text("Rotating Shift").tag(1)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle("New Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let _ = packManager.createPack(name: name.isEmpty ? "My Pack" : name, iconName: selectedIcon, colorHex: selectedColor, scheduleType: scheduleType)
                        onDismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
