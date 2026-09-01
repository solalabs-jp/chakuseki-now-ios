// 接続ボタン
import SwiftUI

struct MainButton: View {
    let title: String

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.brandRed, lineWidth: 1)
                .frame(width: isAnimating ? 192 : 80, height: isAnimating ? 192 : 80)
                .opacity(isAnimating ? 0 : 1)
                .animation(
                    .easeOut(duration: 2.0).repeatForever(autoreverses: false),
                    value: isAnimating
                )

            Circle()
                .stroke(AppColors.brandRed, lineWidth: 1)
                .frame(width: isAnimating ? 192 : 80, height: isAnimating ? 192 : 80)
                .opacity(isAnimating ? 0 : 1)
                .animation(
                    .easeOut(duration: 2.0).delay(1.0).repeatForever(autoreverses: false),
                    value: isAnimating
                )

            Circle()
                .fill(AppColors.brandRed)
                .frame(width: 80, height: 80)
                .shadow(color: AppColors.strongShadow, radius: 10, x: 0, y: 5)

            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 27, height: 30)
        }
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
}
