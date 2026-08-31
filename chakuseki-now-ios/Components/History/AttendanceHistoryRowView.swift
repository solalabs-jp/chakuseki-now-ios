import SwiftUI

struct AttendanceHistoryRowView: View {
    let record: AttendanceRecord

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("第\(record.sessionNumber)回")
                    .font(.system(size: 16))

                Text(Self.dateFormatter.string(from: record.date))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            AttendanceStatusBadgeView(status: record.status)
        }
        .padding()
        .background(record.status.rowBackgroundColor)
    }
}

#Preview {
    AttendanceHistoryRowView(
        record: AttendanceRecord(sessionNumber: 1, date: .now, status: .attendance)
    )
}
