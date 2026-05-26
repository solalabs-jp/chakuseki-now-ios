import SwiftUI

struct LoginButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("ログイン")
                    .font(.system(size: 16, weight: .semibold))

                Image("login")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 13.5, height: 13.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.brandRed)
            .foregroundColor(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginButton {}
        .padding()
}
