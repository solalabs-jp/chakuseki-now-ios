// テキストボックス&送信ボタン
import SwiftUI

struct MessageInputField: View {
    @State private var inputText: String = ""
    var onSend: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                TextField("一限のお題を入力...", text: $inputText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 166)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color(red: 1, green: 0.97, blue: 0.97))
            .cornerRadius(12)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(Color(red: 0.89, green: 0.75, blue: 0.72), lineWidth: 1)
            )
            
            // 2. ボタンの中身を Text に変更
            Button(action: {
                onSend(inputText)
                inputText = ""
            }) {
                HStack(alignment: .center, spacing: 8) {
                    Image("check")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("回答して出席")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(inputText.isEmpty ? Color.gray : Color(red: 0.83, green: 0.18, blue: 0.15))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty) // 入力がない時はボタンを無効化
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.5)
                .stroke(Color(red: 0.89, green: 0.75, blue: 0.72), lineWidth: 1)
        )
    }
}
