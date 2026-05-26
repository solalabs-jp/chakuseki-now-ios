import SwiftUI

struct SelectedDateDisplayView: View {
    let date: Date?
    
    var body: some View {
        let displayDate = date ?? .now
        VStack(spacing: TimetableStyle.topPadding) {
            Text(displayDate.formatted(.dateTime.month().day().weekday(.abbreviated).locale(CalendarStyle.locale)))
                .font(TimetableStyle.dateFont)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top, .leading], TimetableStyle.horizontalPadding)
            
            VStack(spacing: TimetableStyle.spacing) {
                SubjectButtonView(subjectName: "AWS演習", date: displayDate, timeString: "09:15 - 10:45", status: .attendance)
                SubjectButtonView(subjectName: "テスト1", date: displayDate, timeString: "11:00 - 12:30", status: .absence)
                SubjectButtonView(subjectName: "テスト2", date: displayDate, timeString: "13:20 - 14:50", status: .tardiness)
                SubjectButtonView(subjectName: "テスト3", date: displayDate, timeString: "15:05 - 16:00", status: .earlyDeparture)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SelectedDateDisplayView(date: .now)
}
