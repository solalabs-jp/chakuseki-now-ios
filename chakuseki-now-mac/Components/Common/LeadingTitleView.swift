import SwiftUI

struct LeadingTitleView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold))
            .kerning(0.4)
            .foregroundColor(AppColors.labelPrimary)
            .frame(width: 241, height: 41, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    LeadingTitleView(title: "ようこそ")
}
