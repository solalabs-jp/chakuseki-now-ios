import SwiftUI

struct HomeAttendanceContentView: View {
    let submittedAnswer: String?
    let submittedTime: Date?
    let onSubmit: (String) -> Void

    var body: some View {
        Group {
            if let submittedAnswer, let submittedTime {
                AttendanceResultView(answer: submittedAnswer, time: submittedTime)
            } else {
                MessageInputField { sentText in
                    onSubmit(sentText)
                }
            }
        }
    }
}

#Preview {
    HomeAttendanceContentView(
        submittedAnswer: nil,
        submittedTime: nil
    ) { _ in }
}
