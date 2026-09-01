import SwiftUI

struct HomeAttendanceContentView: View {
    let submittedAnswer: String?
    let submittedTime: Date?
    /// コメントを送信し、確定できたら `true` を返す。失敗時は入力欄を再表示して再送できるようにする。
    let onSubmit: (String) async -> Bool

    var body: some View {
        Group {
            if let submittedAnswer, let submittedTime {
                AttendanceResultView(answer: submittedAnswer, time: submittedTime)
            } else {
                MessageInputField(onSend: onSubmit)
            }
        }
    }
}

#Preview {
    HomeAttendanceContentView(
        submittedAnswer: nil,
        submittedTime: nil
    ) { _ in true }
}
