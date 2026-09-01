import SwiftUI
import UIKit

struct LoginLabeledInputField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?

    init(
        _ title: String,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) {
        self.title = title
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textContentType = textContentType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(
                    Font.custom("Lexend", size: 13)
                        .weight(.semibold)
                )
                .foregroundColor(AppColors.brownText)
                .frame(maxWidth: .infinity, minHeight: 17, maxHeight: 17, alignment: .leading)
                .padding(.leading, 28)

            LoginInputField(
                text: $text,
                isSecure: isSecure,
                keyboardType: keyboardType,
                textContentType: textContentType
            )
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    @Previewable @State var text = ""

    LoginLabeledInputField("メールアドレス (Email)", text: $text, keyboardType: .emailAddress)
        .frame(width: 370)
}
