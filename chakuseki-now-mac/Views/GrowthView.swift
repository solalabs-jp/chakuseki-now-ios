import SwiftUI

struct GrowthView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LeadingTitleView(title: "マイページ")
                .padding(.horizontal, -16)

            ProfileCardView()
                .padding(.top, Constants.headerTopSpacing)
                .padding(.horizontal, -16)

            Spacer()
        }
        .padding(.top, 1.5)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    GrowthView()
}
