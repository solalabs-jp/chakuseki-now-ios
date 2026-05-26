import SwiftUI

struct LoginView: View {
    let onLogin: () -> Void

    @State private var studentID = ""
    @State private var password = ""

    var body: some View {
        ZStack(alignment: .top) {
            LoginTitleView()

            LoginCardView(
                studentID: $studentID,
                password: $password,
                onLogin: onLogin
            )
            .padding(.top, 218)

            ForgotPasswordTextView()
                .padding(.top, 538)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    LoginView {}
}
