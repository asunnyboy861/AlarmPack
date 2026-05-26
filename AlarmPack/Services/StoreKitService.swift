import Foundation
import StoreKit

@Observable
@MainActor
final class StoreKitService {
    static let shared = StoreKitService()

    var isPro: Bool = false
    var product: Product?
    var isLoading = false
    var purchaseError: String?

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
        purchaseError = nil
        guard let product = product else {
            purchaseError = "Product not available. Please try again later."
            return false
        }
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
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed. Please try again."
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
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == "com.zzoutuo.AlarmPack.pro" {
                        let isValid = transaction.revocationDate == nil
                        await MainActor.run {
                            StoreKitService.shared.isPro = isValid
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
