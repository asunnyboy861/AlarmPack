import SwiftUI

struct PackListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PackListViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.packs.isEmpty {
                        emptyState
                    } else {
                        packList(vm)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("AlarmPack")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        viewModel?.showAddPackOrPaywall()
                    } label: {
                        Label("New Pack", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showAddPack ?? false },
                set: { viewModel?.showAddPack = $0 }
            )) {
                if let vm = viewModel {
                    AddPackView(packManager: PackManager(modelContext: modelContext)) {
                        vm.fetchPacks()
                        vm.showAddPack = false
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showPaywall ?? false },
                set: { viewModel?.showPaywall = $0 }
            )) {
                PaywallView()
            }
            .overlay {
                if let vm = viewModel, vm.showToast {
                    toastView(vm.toastMessage ?? "")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = PackListViewModel(modelContext: modelContext)
            }
            viewModel?.fetchPacks()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Alarm Packs",
            systemImage: "alarm",
            description: Text("Create your first alarm pack to get started")
        )
    }

    private func packList(_ vm: PackListViewModel) -> some View {
        List {
            ForEach(vm.packs, id: \.id) { pack in
                NavigationLink {
                    PackDetailView(pack: pack)
                } label: {
                    PackCardView(pack: pack) {
                        Task { await vm.togglePack(pack) }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await vm.deletePack(pack) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func toastView(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.75))
                .clipShape(Capsule())
                .transition(.move(edge: .bottom).combined(with: .opacity))
            Spacer().frame(height: 80)
        }
        .animation(.easeInOut(duration: 0.3), value: message)
    }
}
