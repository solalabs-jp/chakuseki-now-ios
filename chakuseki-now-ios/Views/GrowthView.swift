import SwiftUI

struct GrowthView: View {
    @State private var auth = AuthService.shared

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

                    // TODO: レベル・EXP（育成機能）は未実装のため一旦非表示
                    // ProfileCardView()
                }
                .padding(.top, 24)
            }
        }
        .padding(.top, 1.5)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    GrowthView()
}
