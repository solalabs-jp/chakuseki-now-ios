import SwiftUI

struct AttendanceResultView: View {
    let answer: String
    let time: Date
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("打刻時間: \(timeFormatter.string(from: time))")
                    .font(.subheadline)
                
                Text("送信した回答:")
                    .font(.subheadline)
                Text(answer)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}
