import SwiftUI

struct HomeView: View {
    @State private var currentStatus: StatusView.Status = .searching
    @State private var submittedAnswer: String? = nil
    @State private var submittedTime: Date? = nil

    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                GreetingView(isAttended: submittedAnswer != nil)
                Spacer() 
                
            }
            StatusView(status: currentStatus, isAttended: submittedAnswer != nil)
                .padding(.horizontal, -16)

            Spacer() 

            // 2. 真ん中に置きたいコンテンツ（ステータスとボタン）
            VStack(spacing: 30) { // まとめて真ん中に寄せる
                

               if currentStatus == .searching {
    // 1. ボタンと説明テキストを縦に並べるためのVStack
    VStack(spacing: 15) {
        MainButton(title: "接続を開始する") {
            // ここはボタンが押された時の「命令」だけを書く場所
            currentStatus = .connecting
        }
        
        // 2. ボタンの外にテキストを配置する
        Text("デバイスを机の上に置き、しばらくお待ちください。")
            .font(.subheadline) // 少し小さめにする
            .foregroundColor(.secondary) // 文字色を少し薄くする
    }
} else {
                    // 接続成功時の表示
                    VStack {
                        if let answer = submittedAnswer, let time = submittedTime {
                            AttendanceResultView(answer: answer, time: time)
                        } else {
                            MessageInputField { sentText in
                                print("送信されました: \(sentText)")
                                submittedAnswer = sentText
                                submittedTime = Date()
                            }
                            .padding(.horizontal, -16)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity) // 横幅いっぱいにして中央揃えにする

            Spacer() 
        }
        .padding()
    }
}
