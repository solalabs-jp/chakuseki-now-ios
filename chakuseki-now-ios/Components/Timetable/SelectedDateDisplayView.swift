import SwiftUI

struct SelectedDateDisplayView: View {
    let date: Date?
    var entries: [TimetableEntry] = []
    var state: LoadState = .loaded

    var body: some View {
        let displayDate = date ?? .now
        VStack(spacing: TimetableStyle.topPadding) {
            Text(displayDate.formatted(.dateTime.month().day().weekday(.abbreviated).locale(CalendarStyle.locale)))
                .font(TimetableStyle.dateFont)
                .frame(maxWidth: .infinity, alignment: .leading)

            content(for: displayDate)
        }
    }

    @ViewBuilder
    private func content(for displayDate: Date) -> some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

        case .failed:
            Text("時間割の取得に失敗しました")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

        case .loaded:
            if entries.isEmpty {
                Text("この日の授業はありません")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: TimetableStyle.spacing) {
                    ForEach(entries) { entry in
                        SubjectButtonView(
                            subjectName: entry.subjectName,
                            scheduleId: entry.scheduleId,
                            date: displayDate,
                            timeString: entry.timeString,
                            status: entry.status,
                            hasEnded: entry.hasEnded
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    SelectedDateDisplayView(
        date: .now,
        entries: [
            TimetableEntry(scheduleId: "s1", subjectName: "ITマネジメント", timeString: "09:15 - 10:45", status: .attendance, hasEnded: true),
            TimetableEntry(scheduleId: "s2", subjectName: "データベース", timeString: "13:20 - 14:50", status: nil, hasEnded: true),
            TimetableEntry(scheduleId: "s3", subjectName: "ネットワーク基礎", timeString: "16:15 - 17:45", status: nil, hasEnded: false)
        ]
    )
}
