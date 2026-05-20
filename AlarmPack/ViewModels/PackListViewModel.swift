import Foundation
import SwiftData

@Observable
@MainActor
final class PackListViewModel {
    var packs: [Pack] = []
    var showPaywall = false
    var showAddPack = false
    var toastMessage: String?
    var showToast = false

    private var modelContext: ModelContext
    private var packManager: PackManager

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.packManager = PackManager(modelContext: modelContext)
    }

    func fetchPacks() {
        var descriptor = FetchDescriptor<Pack>(sortBy: [SortDescriptor(\.sortOrder)])
        descriptor.fetchLimit = 100
        packs = (try? modelContext.fetch(descriptor)) ?? []
    }

    func togglePack(_ pack: Pack) async {
        await packManager.togglePack(pack)
        fetchPacks()
        toastMessage = "\(pack.name) Active"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showToast = false
        }
    }

    func deletePack(_ pack: Pack) async {
        await packManager.deletePack(pack)
        fetchPacks()
    }

    func canCreatePack() -> Bool {
        packManager.canCreatePack(isPro: StoreKitService.shared.isPro)
    }

    func showAddPackOrPaywall() {
        if canCreatePack() {
            showAddPack = true
        } else {
            showPaywall = true
        }
    }
}
