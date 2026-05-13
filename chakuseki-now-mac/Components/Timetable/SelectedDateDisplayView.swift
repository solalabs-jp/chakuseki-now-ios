import SwiftUI

struct SelectedDateDisplayView: View {
    let date: Date?
    
    var body: some View {
        let displayDate = date ?? .now
        VStack(spacing: 16) {
            Text(displayDate.formatted(.dateTime.month().day().weekday(.abbreviated).locale(CalendarStyle.locale)))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top,.leading], 16)
            
            VStack(spacing: 0) {
                SubjectRowView(subjectName: "AWS演習", date: displayDate, status: .attendance)
                    .padding()
                Divider()
                SubjectRowView(subjectName: "テスト1", date: displayDate, status: .absence)
                    .padding()
                Divider()
                SubjectRowView(subjectName: "テスト2", date: displayDate, status: .tardiness)
                    .padding()
                Divider()
                SubjectRowView(subjectName: "テスト3", date: displayDate, status: .earlyDeparture)
                    .padding()
            }
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    SelectedDateDisplayView(date: .now)
}
