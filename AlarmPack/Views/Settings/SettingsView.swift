import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SettingsViewModel?

    private let githubUser = "asunnyboy861"
    private let appName = "AlarmPack"

    var body: some View {
        Group {
            if let vm = viewModel {
                Form {
                    proSection(vm)
                    alarmSection(vm)
                    hapticSection(vm)
                    supportSection()
                    legalSection()
                    aboutSection()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(modelContext: modelContext)
            }
        }
    }

    private func proSection(_ vm: SettingsViewModel) -> some View {
        Section {
            if vm.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.orange)
                    Text("Pro Unlocked")
                        .font(.headline)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                NavigationLink {
                    PaywallView()
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(.orange)
                        Text("Unlock Pro")
                            .font(.headline)
                    }
                }
            }
        } header: {
            Text("Pro")
        }
    }

    private func alarmSection(_ vm: SettingsViewModel) -> some View {
        Section {
            Stepper("Default Snooze: \(vm.defaultSnooze) min", value: Binding(
                get: { vm.defaultSnooze },
                set: { vm.updateDefaultSnooze($0) }
            ), in: 1...30)
        } header: {
            Text("Alarms")
        }
    }

    private func hapticSection(_ vm: SettingsViewModel) -> some View {
        Section {
            Toggle("Haptic Feedback", isOn: Binding(
                get: { vm.hapticEnabled },
                set: { vm.updateHapticEnabled($0) }
            ))
        } header: {
            Text("Feedback")
        }
    }

    private func supportSection() -> some View {
        Section {
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }

            Button {
                Task { await StoreKitService.shared.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.uturn.backward")
            }
        } header: {
            Text("Support")
        }
    }

    private func legalSection() -> some View {
        Section {
            Link("Privacy Policy", destination: URL(string: "https://\(githubUser).github.io/\(appName)/privacy.html")!)
            Link("Support Page", destination: URL(string: "https://\(githubUser).github.io/\(appName)/support.html")!)
        } header: {
            Text("Legal")
        }
    }

    private func aboutSection() -> some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}
