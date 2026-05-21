// テキストボックス&送信ボタン
import SwiftUI

struct MessageInputField: View {
    private let maxInputLineCount = 7
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    var onSend: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            inputTextBox
            
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
                        .foregroundColor(AppColors.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(inputText.isEmpty ? AppColors.brandRedDisabled : AppColors.brandRedDeep)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty) // 入力がない時はボタンを無効化
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
        TextField("一限のお題を入力...", text: .constant(""))
            .textFieldStyle(.plain)
            .opacity(0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 166)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(AppColors.messageInputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $inputText)
                        .font(.body)
                        .focused($isInputFocused)
                        .scrollContentBackground(.hidden)
                        .background(AppColors.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onChange(of: inputText) { _, newValue in
                            let limitedText = limitedText(newValue)

                            if limitedText != newValue {
                                inputText = limitedText
                            }
                        }

                    if inputText.isEmpty {
                        Text("一限のお題を入力...")
                            .font(.body)
                            .foregroundColor(AppColors.placeholderText)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                isInputFocused = true
            }
    }

    private func limitedText(_ text: String) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

        guard lines.count > maxInputLineCount else {
            return text
        }

        return lines.prefix(maxInputLineCount).joined(separator: "\n")
    }
}
