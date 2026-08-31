// テキストボックス&送信ボタン
import SwiftUI

struct MessageInputField: View {
    private let maxInputLineCount = 6
    /// 入力欄の高さ（約3行ぶん）。キーボード表示時でもボタンが画面内に収まるサイズ。
    private let inputBoxHeight: CGFloat = 96

    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    var onSend: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            inputTextBox

            Button(action: {
                onSend(inputText)
                inputText = ""
                isInputFocused = false
            }) {
                HStack(alignment: .center, spacing: 8) {
                    Image("check")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Text("回答して出席")
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(inputText.isEmpty ? AppColors.brandRedDisabled : AppColors.brandRedDeep)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(AppColors.white)
        .cornerRadius(24)
        .shadow(color: AppColors.shadow, radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.5)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }

    private var inputTextBox: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $inputText)
                .font(.body)
                .focused($isInputFocused)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .onChange(of: inputText) { _, newValue in
                    let limited = limitedText(newValue)
                    if limited != newValue { inputText = limited }
                }

            if inputText.isEmpty {
                Text("一言コメントを入力…")
                    .font(.body)
                    .foregroundColor(AppColors.placeholderText)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: inputBoxHeight)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(AppColors.messageInputBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            isInputFocused = true
        }
    }

    private func limitedText(_ text: String) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count > maxInputLineCount else { return text }
        return lines.prefix(maxInputLineCount).joined(separator: "\n")
    }
}

#Preview {
    MessageInputField { _ in }
        .padding()
}
