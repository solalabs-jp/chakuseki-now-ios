import SwiftUI

struct GreetingView: View {
    let isAttended: Bool

    var body: some View {
        Text(isAttended ? "出席しました" : "おはようございます")
            .font(.system(size: 24, weight: .bold))
            .kerning(0.4)
            .foregroundColor(AppColors.labelPrimary)
            .frame(width: 241,height: 41, alignment: .topLeading)
    }
}
