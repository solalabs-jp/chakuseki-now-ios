import SwiftUI

struct GreetingView: View {
    let isAttended: Bool

    var body: some View {
        LeadingTitleView(title: isAttended ? "出席しました" : "おはようございます")
    }
}
