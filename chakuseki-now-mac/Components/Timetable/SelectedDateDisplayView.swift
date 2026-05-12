import SwiftUI

struct SelectedDateDisplayView: View {
    let date: Date?
    
    var body: some View {
        let displayDate = date ?? .now
        VStack {
            Text(displayDate.formatted(.dateTime.year().month().day().weekday(.wide).locale(CalendarStyle.locale)))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            List {
                SubjectRowView(subjectName: "AWS演習", date: displayDate)
                SubjectRowView(subjectName: "テスト1", date: displayDate)
                SubjectRowView(subjectName: "テスト2", date: displayDate)
                SubjectRowView(subjectName: "テスト3", date: displayDate)
            }
        }
    }
}

#Preview {
    SelectedDateDisplayView(date: .now)
}
