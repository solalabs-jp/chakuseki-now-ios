import SwiftUI

struct GrowthView: View {
    @State private var auth = AuthService.shared
    @State private var viewModel = GrowthViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LeadingTitleView(title: "マイページ")

            ScrollView {
                VStack(spacing: 24) {
                    if let profile = auth.currentProfile {
                        ProfileAccountSectionView(profile: profile) {
                            auth.signOut()
                        }
                    }

                    switch viewModel.state {
                    case .idle, .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)

                    case .failed(let message):
                        VStack(spacing: 8) {
                            Text("読み込みに失敗しました")
                                .font(.headline)
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("再試行") {
                                Task { await viewModel.loadIfNeeded(for: auth.currentUserId) }
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)

                    case .loaded:
                        ProfileCardView(levelInfo: viewModel.levelInfo)
                    }
                }
                .padding(.top, 24)
            }
        }
        .padding(.top, 1.5)
        .padding(.horizontal)
        .padding(.bottom)
        .task {
            await viewModel.loadIfNeeded(for: auth.currentUserId)
        }
        .onChange(of: auth.currentUserId) { _, newUserId in
            Task {
                await viewModel.loadIfNeeded(for: newUserId)
            }
        }
    }
}

#Preview {
    GrowthView()
}
