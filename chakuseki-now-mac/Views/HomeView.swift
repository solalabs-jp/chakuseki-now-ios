import SwiftUI

struct HomeView: View {
    let resetTrigger: Int

    @State private var currentStatus: StatusView.Status = .searching
    @State private var submittedAnswer: String? = nil
    @State private var submittedTime: Date? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                GreetingView(isAttended: submittedAnswer != nil)
                Spacer() 
            }

            StatusView(status: currentStatus, isAttended: submittedAnswer != nil)
                .padding(.top, 61)
                .padding(.horizontal, -16)

            if currentStatus == .searching {
                Spacer()

                VStack(spacing: 15) {
                    MainButton(title: "接続を開始する") {
                        currentStatus = .connecting
                    }

                    Text("デバイスを机の上に置き、\nしばらくお待ちください。")
                        .font(
                            Font.custom("SF Pro", size: 16)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.36, green: 0.25, blue: 0.24))
                        .frame(width: 244.12, height: 42, alignment: .center)
                }
                .frame(maxWidth: .infinity)

                Spacer()
            } else {
                Group {
                    if let answer = submittedAnswer, let time = submittedTime {
                        AttendanceResultView(answer: answer, time: time)
                    } else {
                        MessageInputField { sentText in
                            print("送信されました: \(sentText)")
                            submittedAnswer = sentText
                            submittedTime = Date()
                        }
                    }
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
    }
}

#Preview {
    HomeView(resetTrigger: 0)
}
