import SwiftUI

struct ForgotPasswordTextView: View {
    var body: some View {
        Text("パスワードを忘れた場合")
            .font(
                Font.custom("SF Pro", size: 15)
                    .weight(.medium)
            )
            .foregroundColor(AppColors.forgotPasswordText)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ForgotPasswordTextView()
}
