// 接続ボタン
import SwiftUI

struct MainButton: View {
    let title: String
    let action: () -> Void // ボタンが押された時に実行する処理を受け取る

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity) // 横幅いっぱいに広げる場合
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}
