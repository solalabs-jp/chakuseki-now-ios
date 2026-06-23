import SwiftUI

struct HomeView: View {
    let resetTrigger: Int

    @State private var currentStatus: StatusView.Status = .searching
    @State private var submittedAnswer: String? = nil
    @State private var submittedTime: Date? = nil
    @State private var detectedUUID: UUID? = nil

    var teacherName: String? {
        guard let uuidString = detectedUUID?.uuidString.uppercased() else { return nil }
        if uuidString == "01020304-0506-0708-090A-0B0C0D0E0F10" {
            return "れんし"
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GreetingView(isAttended: submittedAnswer != nil)
                .padding(.horizontal, -16)

            StatusView(status: currentStatus, isAttended: submittedAnswer != nil, teacherName: teacherName)
                .padding(.top, 61)
                .padding(.horizontal, -16)

            if currentStatus == .searching {
                Spacer()

                HomeSearchingContentView { uuid in
                    detectedUUID = uuid
                    currentStatus = .connecting
                }

                Spacer()
            } else {
                HomeAttendanceContentView(
                    submittedAnswer: submittedAnswer,
                    submittedTime: submittedTime
                ) { sentText in
                    print("送信されました: \(sentText)")
                    submittedAnswer = sentText
                    submittedTime = Date()
                }
                .padding(.top, 24)
                .padding(.horizontal, -16)

                Spacer()
            }
        }
        .padding(.top, 1.5)
        .padding(.horizontal)
        .padding(.bottom)
        .onChange(of: resetTrigger) { _, _ in
            resetToFirstPage()
        }
    }

    private func resetToFirstPage() {
        currentStatus = .searching
        submittedAnswer = nil
        submittedTime = nil
        detectedUUID = nil
    }
}

#Preview {
    HomeView(resetTrigger: 0)
}
