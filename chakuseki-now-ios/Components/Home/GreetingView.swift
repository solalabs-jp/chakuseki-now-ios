import SwiftUI

struct GreetingView: View {
    let isAttended: Bool

    @State private var auth = AuthService.shared

    /// ログイン中ユーザーの苗字（氏名の最初の空白区切りトークン）。
    private var surname: String? {
        guard let name = auth.currentProfile?.name else { return nil }
        return name.split(whereSeparator: { $0.isWhitespace }).first.map(String.init)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(isAttended ? "出席しました" : "おはようございます")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppColors.labelPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if let surname {
                Text("\(surname)さん")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.labelPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

#Preview {
    GreetingView(isAttended: false)
        .padding(.horizontal)
}
