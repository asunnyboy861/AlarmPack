import SwiftUI
import SwiftData

struct AddAlarmView: View {
    let pack: Pack
    let modelContext: ModelContext
    let onDismiss: () -> Void

    @State private var viewModel: AlarmViewModel?
    @State private var date = Date()
    @Environment(\.dismiss) private var dismiss

    private let dayNames = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }

                Section("Label") {
                    TextField("Alarm label", text: Binding(
                        get: { viewModel?.label ?? "" },
                        set: { viewModel?.label = $0 }
                    ))
                }

                Section("Repeat") {
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { index in
                            Circle()
                                .fill((viewModel?.repeatDays.contains(index) ?? false) ? Color.orange : Color.clear)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(dayNames[index])
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle((viewModel?.repeatDays.contains(index) ?? false) ? .white : .secondary)
                                )
                                .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
                                .onTapGesture {
                                    viewModel?.repeatDays = {
                                        var days = viewModel?.repeatDays ?? []
                                        if days.contains(index) { days.remove(index) } else { days.insert(index) }
                                        return days
                                    }()
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Section("Snooze") {
                    Stepper("\(viewModel?.snoozeMinutes ?? 9) minutes", value: Binding(
                        get: { viewModel?.snoozeMinutes ?? 9 },
                        set: { viewModel?.snoozeMinutes = $0 }
                    ), in: 1...30)
                }
            }
            .navigationTitle("Add Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let vm = viewModel {
                                let cal = Calendar.current
                                vm.hour = cal.component(.hour, from: date)
                                vm.minute = cal.component(.minute, from: date)
                                let success = await vm.saveAlarm()
                                if success { onDismiss() }
                            }
                        }
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = AlarmViewModel(pack: pack, modelContext: modelContext)
                    let cal = Calendar.current
                    var components = DateComponents()
                    components.hour = 7
                    components.minute = 0
                    date = cal.date(from: components) ?? Date()
                }
            }
            .onChange(of: date) { _, newValue in
                let cal = Calendar.current
                viewModel?.hour = cal.component(.hour, from: newValue)
                viewModel?.minute = cal.component(.minute, from: newValue)
            }
        }
    }
}
