import SwiftUI

struct LoginTitleView: View {
    var body: some View {
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
}

#Preview {
    LoginTitleView()
}
