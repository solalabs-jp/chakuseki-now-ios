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
            if let userId = auth.currentUserId {
                await viewModel.load(for: userId)
            }
        }
        .onChange(of: auth.currentUserId) { _, newUserId in
            Task {
                await viewModel.load(for: newUserId)
            }
        }
    }
}

#Preview {
    GrowthView()
}
