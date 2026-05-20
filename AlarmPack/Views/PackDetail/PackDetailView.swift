import SwiftUI

struct PackDetailView: View {
    let pack: Pack
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PackDetailViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                alarmList(vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(pack.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        vm()?.showSkipAllConfirmation = true
                    } label: {
                        Label("Skip All Tomorrow", systemImage: "moonrise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    vm()?.showAddAlarmOrPaywall()
                } label: {
                    Label("Add Alarm", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showAddAlarm ?? false },
            set: { viewModel?.showAddAlarm = $0 }
        )) {
            if let vm = viewModel {
                AddAlarmView(pack: pack, modelContext: modelContext) {
                    viewModel?.pack = pack
                    viewModel?.showAddAlarm = false
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showPaywall ?? false },
            set: { viewModel?.showPaywall = $0 }
        )) {
            PaywallView()
        }
        .confirmationDialog("Skip All Alarms Tomorrow?", isPresented: Binding(
            get: { viewModel?.showSkipAllConfirmation ?? false },
            set: { viewModel?.showSkipAllConfirmation = $0 }
        ), titleVisibility: .visible) {
            Button("Skip All Tomorrow") {
                Task { await viewModel?.skipAllTomorrow() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            if viewModel == nil {
                viewModel = PackDetailViewModel(pack: pack, modelContext: modelContext)
            }
        }
    }

    private func vm() -> PackDetailViewModel? { viewModel }

    private func alarmList(_ vm: PackDetailViewModel) -> some View {
        List {
            if vm.alarms.isEmpty {
                ContentUnavailableView(
                    "No Alarms",
                    systemImage: "alarm",
                    description: Text("Add your first alarm to this pack")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(vm.alarms, id: \.id) { alarm in
                    AlarmRowView(alarm: alarm, isPro: StoreKitService.shared.isPro) {
                        Task { await vm.toggleAlarm(alarm) }
                    } onSkip: {
                        Task { await vm.skipAlarm(alarm) }
                    } onUnskip: {
                        Task { await vm.unskipAlarm(alarm) }
                    } onEdit: {
                        // Navigation to edit handled by row tap
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await vm.deleteAlarm(alarm) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
