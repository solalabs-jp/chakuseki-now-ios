import SwiftUI

struct HomeSearchingContentView: View {
    let onStartConnection: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            MainButton(title: "接続を開始する", action: onStartConnection)

            Text("デバイスを机の上に置き、\nしばらくお待ちください。")
                .font(
                    Font.custom("SF Pro", size: 16)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.brownText)
                .frame(width: 244.12, height: 42, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeSearchingContentView {}
}
