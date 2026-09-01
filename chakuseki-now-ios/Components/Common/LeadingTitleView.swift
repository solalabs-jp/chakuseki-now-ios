import SwiftUI

/// 各画面共通の大見出し。`NavigationStack` を使わない画面でも見え方を揃えるためのコンポーネント。
struct LeadingTitleView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(AppColors.labelPrimary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
            .padding(.bottom, 8)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        LeadingTitleView(title: "おはようございます")
        LeadingTitleView(title: "履歴を確認しよう")
        LeadingTitleView(title: "マイページ")
    }
    .padding(.horizontal)
}
