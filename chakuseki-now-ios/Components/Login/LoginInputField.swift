import SwiftUI
import UIKit

struct LoginInputField: View {
    @Binding var text: String
    let isSecure: Bool
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .textFieldStyle(.plain)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(AppColors.brownText)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.leading, 9)
        .padding(.trailing, 16)
        .padding(.top, 14)
        .padding(.bottom, 9)
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .top)
        .background(AppColors.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    @Previewable @State var text = ""

    LoginInputField(text: $text, isSecure: false)
        .frame(width: 320)
}
