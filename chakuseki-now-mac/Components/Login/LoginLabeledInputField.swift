import SwiftUI

struct LoginLabeledInputField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool

    init(_ title: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self._text = text
        self.isSecure = isSecure
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

            LoginInputField(text: $text, isSecure: isSecure)
                .padding(.horizontal, 24)
        }
    }
}

#Preview {
    @Previewable @State var text = ""

    LoginLabeledInputField("学籍番号 (Student ID)", text: $text)
        .frame(width: 370)
}
