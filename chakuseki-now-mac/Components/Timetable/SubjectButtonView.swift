import SwiftUI

struct SubjectButtonView: View {
    let subjectName: String
    let date: Date
    let status: AttendanceStatus
    
    var body: some View {
        NavigationLink(destination: HistoryDetailView(subjectName: subjectName, date: date)) {
            SubjectRowView(subjectName: subjectName, date: date, status: status)
                .padding()
                .background(TimetableStyle.rowBackground)
                .cornerRadius(TimetableStyle.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SubjectButtonView(subjectName: "AWS演習", date: .now, status: .attendance)
        .padding()
}
