import Foundation
import StoreKit

@Observable
@MainActor
final class StoreKitService {
    static let shared = StoreKitService()

    var isPro: Bool = false
    var product: Product?
    var isLoading = false

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProduct(); await checkPurchased() }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: ["com.zzoutuo.AlarmPack.pro"])
            product = products.first
        } catch {
            print("StoreKit load product error: \(error)")
        }
    }

    func purchasePro() async -> Bool {
        guard let product = product else { return false }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isPro = true
                    await transaction.finish()
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("StoreKit purchase error: \(error)")
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            print("StoreKit restore error: \(error)")
        }
    }

    private func checkPurchased() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == "com.zzoutuo.AlarmPack.pro" {
                    isPro = transaction.revocationDate == nil
                    return
                }
            }
        }
        isPro = false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == "com.zzoutuo.AlarmPack.pro" {
                        await MainActor.run { self?.isPro = transaction.revocationDate == nil }
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
