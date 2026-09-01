import SwiftUI

struct LoginTitleView: View {
    var body: some View {
        ZStack(alignment: .top) {
            LeadingTitleView(title: "ようこそ")
                .padding(.top, 1.5)
                .padding(.horizontal)

            Text("着席なう")
                .font(
                    Font.custom("SF Pro", size: 34)
                        .weight(.semibold)
                )
                .kerning(0.37)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.loginTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 121)
                .padding(.horizontal, 132)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    LoginTitleView()
}
