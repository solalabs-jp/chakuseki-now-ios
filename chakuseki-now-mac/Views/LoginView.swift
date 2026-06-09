import SwiftUI

struct LoginView: View {
    let onLogin: () -> Void

    @State private var studentID = ""
    @State private var password = ""
    @State private var isShowingForgotPassword = false

    var body: some View {
        ZStack(alignment: .top) {
            LoginTitleView()

            LoginCardView(
                studentID: $studentID,
                password: $password,
                onLogin: onLogin
            )
            .padding(.top, 218)

            ForgotPasswordTextView {
                isShowingForgotPassword = true
            }
                .padding(.top, 538)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $isShowingForgotPassword) {
            ForgotPasswordView()
        }
    }
}

#Preview {
    LoginView {}
}
