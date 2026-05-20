import SwiftUI

struct LoginPageView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            VStack(alignment: .leading, spacing: 0) {
                Text("ログイン")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Constants.LabelsVibrantPrimary)

                Text("このページは未ログイン時に表示されます。")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 20)

                Text("詳細なUIはここから作成していけます。")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color(red: 1, green: 0.97, blue: 0.97))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(Color(red: 1, green: 0.89, blue: 0.87), lineWidth: 1)
            )
            .padding(.top, 218)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.bottom)
    }
}

#Preview {
    LoginPageView()
}
