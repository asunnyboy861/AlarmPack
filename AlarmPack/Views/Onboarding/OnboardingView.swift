import SwiftUI
import SwiftData
#if canImport(AlarmKit)
import AlarmKit
#endif

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: OnboardingViewModel?
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        if let vm = viewModel {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Image(systemName: "alarm")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                    .padding(.bottom, 16)

                Text("Welcome to AlarmPack")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)

                Text("Group your alarms into Packs.\nSwitch with one tap.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)

                #if canImport(AlarmKit)
                if #available(iOS 26, *) {
                    Button {
                        requestAlarmPermission()
                    } label: {
                        Label("Enable Alarm Permissions", systemImage: "bell.badge")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                } else {
                    Button {
                        requestNotificationPermission()
                    } label: {
                        Label("Enable Notifications", systemImage: "bell.badge")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                #else
                Button {
                    requestNotificationPermission()
                } label: {
                    Label("Enable Notifications", systemImage: "bell.badge")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                #endif

                Text("Quick Start Templates")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(vm.templates, id: \.name) { template in
                            templateCard(template, vm: vm)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button {
                    if vm.selectedTemplates.isEmpty {
                        vm.toggleTemplate("Work")
                    }
                    Task {
                        let success = await vm.completeOnboarding()
                        if success {
                            hasCompletedOnboarding = true
                        }
                    }
                } label: {
                    Text(vm.selectedTemplates.isEmpty ? "Start with Work Pack" : "Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
        } else {
            ProgressView()
                .onAppear {
                    viewModel = OnboardingViewModel(modelContext: modelContext)
                }
        }
    }

    private func templateCard(_ template: (name: String, icon: String, color: String, alarms: [(hour: Int, minute: Int, label: String)]), vm: OnboardingViewModel) -> some View {
        let isSelected = vm.selectedTemplates.contains(template.name)
        return Button {
            vm.toggleTemplate(template.name)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: template.color))

                Text(template.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(template.alarms.count) alarms")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color(hex: template.color).opacity(0.15) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: template.color) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    #if canImport(AlarmKit)
    @available(iOS 26, *)
    private func requestAlarmPermission() {
        Task {
            do {
                let alarmManager = AlarmManager.shared
                _ = try await alarmManager.requestAuthorization()
            } catch {
                print("AlarmKit permission error: \(error)")
            }
        }
    }
    #endif

    private func requestNotificationPermission() {
        Task {
            _ = await AlarmScheduler.shared.requestNotificationPermission()
        }
    }
}
