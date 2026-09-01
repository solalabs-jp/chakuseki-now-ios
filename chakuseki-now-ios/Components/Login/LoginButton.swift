import SwiftUI

struct LoginButton: View {
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(AppColors.white)
                } else {
                    Text("ログイン")
                        .font(.system(size: 16, weight: .semibold))

                    Image("login")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 13.5, height: 13.5)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.brandRed)
            .foregroundColor(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    VStack {
        LoginButton {}
        LoginButton(action: {}, isLoading: true)
    }
    .padding()
}
