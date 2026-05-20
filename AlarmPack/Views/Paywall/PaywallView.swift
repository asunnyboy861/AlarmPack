import SwiftUI

struct PaywallView: View {
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    private let features: [(icon: String, title: String, desc: String)] = [
        ("infinity", "Unlimited Packs", "Create as many alarm packs as you need"),
        ("alarm", "Unlimited Alarms", "No limit on alarms per pack"),
        ("arrow.triangle.2.circlepath", "Shift Scheduling", "Auto-switch packs on rotating shifts"),
        ("moonrise", "Skip Alarms", "Skip next alarm with one tap"),
        ("speaker.wave.2", "Custom Sounds", "Choose from premium alarm sounds"),
        ("widget", "Advanced Widgets", "More widget styles and quick actions")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("Unlock AlarmPack Pro")
                        .font(.title.bold())

                    Text("One-time purchase. Yours forever.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 16) {
                        ForEach(features, id: \.icon) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: feature.icon)
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(feature.desc)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        Button {
                            Task { await purchasePro() }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Unlock Pro — $2.99")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .disabled(isLoading)

                        Button {
                            Task { await StoreKitService.shared.restorePurchases() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func purchasePro() async {
        isLoading = true
        let success = await StoreKitService.shared.purchasePro()
        isLoading = false
        if success {
            dismiss()
        }
    }
}
