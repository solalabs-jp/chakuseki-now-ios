import SwiftUI

struct LoginView: View {
    let auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var isShowingForgotPassword = false

    var body: some View {
        ZStack(alignment: .top) {
            LoginTitleView()

            LoginCardView(
                email: $email,
                password: $password,
                errorMessage: auth.errorMessage,
                isProcessing: auth.isProcessing,
                onLogin: signIn
            )
            .frame(maxWidth: 420)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .padding(.top, 218)

            ForgotPasswordTextView {
                isShowingForgotPassword = true
            }
                .padding(.horizontal, 24)
                .padding(.top, 538)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $isShowingForgotPassword) {
            ForgotPasswordView()
        }
    }

    private func signIn() {
        Task { await auth.signIn(email: email, password: password) }
    }
}

#Preview {
    LoginView(auth: .shared)
}
