// テキストボックス&送信ボタン
import SwiftUI

struct MessageInputField: View {
    @State private var inputText: String = ""
    var onSend: (String) -> Void

    var body: some View {
        // 1. VStack に変えて縦並びにする
        VStack(spacing: 12) {
            TextField("一限のお題を入力...", text: $inputText)
                .textFieldStyle(.roundedBorder)
            
            // 2. ボタンの中身を Text に変更
            Button(action: {
                onSend(inputText)
                inputText = ""
            }) {
                Text("回答して出席")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity) // 3. ボタンを横幅いっぱいに広げる
                    .padding(.vertical, 10)
                    .background(inputText.isEmpty ? Color.gray : Color.blue) // 入力がない時はグレーにする
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(inputText.isEmpty) // 入力がない時はボタンを無効化
        }
        .padding()
    }
}
