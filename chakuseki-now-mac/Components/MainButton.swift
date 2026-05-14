// 接続ボタン
import SwiftUI

struct MainButton: View {
    let title: String
    let action: () -> Void // ボタンが押された時に実行する処理を受け取る

    @State private var isAnimating: Bool = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // 波紋アニメーション1
                Circle()
                    .stroke(Color(red: 211/255, green: 45/255, blue: 38/255), lineWidth: 1)
                    .frame(width: isAnimating ? 192 : 80, height: isAnimating ? 192 : 80)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 2.0).repeatForever(autoreverses: false),
                        value: isAnimating
                    )

                // 波紋アニメーション2（1秒遅れ）
                Circle()
                    .stroke(Color(red: 211/255, green: 45/255, blue: 38/255), lineWidth: 1)
                    .frame(width: isAnimating ? 192 : 80, height: isAnimating ? 192 : 80)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 2.0).delay(1.0).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                // 内側の赤い円（塗りつぶし）
                Circle()
                    .fill(Color(red: 211/255, green: 45/255, blue: 38/255))
                    .frame(width: 80, height: 80)
                    // 浮き出ているような影を追加
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                
                // 真ん中のアイコン
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 30)
            }
            .padding() // 周囲に余白を持たせる
            .onAppear {
                isAnimating = true
            }
        }
        .buttonStyle(.plain) // macOSデフォルトのボタン背景を消す
    }
}
