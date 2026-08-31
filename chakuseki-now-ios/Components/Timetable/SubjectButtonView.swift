import SwiftUI

struct SubjectButtonView: View {
    let subjectName: String
    let scheduleId: String
    let date: Date
    let timeString: String
    let status: AttendanceStatus?
    var hasEnded: Bool = false

    var body: some View {
        NavigationLink(destination: HistoryDetailView(subjectName: subjectName, scheduleId: scheduleId)) {
            SubjectRowView(subjectName: subjectName, date: date, timeString: timeString, status: status, hasEnded: hasEnded)
                .padding()
                .background(TimetableStyle.rowBackground)
                .cornerRadius(TimetableStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: TimetableStyle.cornerRadius)
                        .stroke(TimetableStyle.outlineColor, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SubjectButtonView(subjectName: "AWS演習", scheduleId: "schedule-001", date: .now, timeString: "09:15 - 10:45", status: .attendance)
        .padding()
}
