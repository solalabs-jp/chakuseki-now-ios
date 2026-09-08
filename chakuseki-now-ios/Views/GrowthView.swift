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

                    ProfileCardView(records: viewModel.records)
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
