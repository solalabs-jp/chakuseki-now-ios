import SwiftUI

struct LoginCardView: View {
    @Binding var studentID: String
    @Binding var password: String

    let onLogin: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            LoginLabeledInputField("学籍番号 (Student ID)", text: $studentID)
                .padding(.top, 25)

            LoginButton(action: onLogin)
                .padding(.top, 186)
                .padding(.horizontal, 24)

            LoginLabeledInputField("パスワード (Password)", text: $password, isSecure: true)
                .padding(.top, 95)
        }
        .frame(width: 370, height: 256, alignment: .topLeading)
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
    @Previewable @State var studentID = ""
    @Previewable @State var password = ""

    LoginCardView(studentID: $studentID, password: $password) {}
}
