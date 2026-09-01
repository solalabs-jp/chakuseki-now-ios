import SwiftUI

struct ForgotPasswordTextView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("パスワードを忘れた場合")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.medium)
                )
                .foregroundColor(AppColors.forgotPasswordText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ForgotPasswordTextView {}
}
