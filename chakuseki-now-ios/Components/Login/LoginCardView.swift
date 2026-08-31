import SwiftUI

struct LoginCardView: View {
    @Binding var email: String
    @Binding var password: String

    var errorMessage: String? = nil
    var isProcessing: Bool = false
    let onLogin: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            LoginLabeledInputField(
                "メールアドレス (Email)",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .username
            )
            .padding(.top, 25)

            LoginButton(action: onLogin, isLoading: isProcessing)
                .padding(.top, 186)
                .padding(.horizontal, 24)

            LoginLabeledInputField(
                "パスワード (Password)",
                text: $password,
                isSecure: true,
                textContentType: .password
            )
            .padding(.top, 95)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.statusAbsence)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 236)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 256)
        .background(AppColors.loginCardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.loginCardShadow, radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(AppColors.loginCardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""

    LoginCardView(
        email: $email,
        password: $password,
        errorMessage: "メールアドレスまたはパスワードが正しくありません",
        onLogin: {}
    )
}
