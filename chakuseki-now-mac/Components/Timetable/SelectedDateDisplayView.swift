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
                SubjectButtonView(subjectName: "AWS演習", date: displayDate, status: .attendance)
                SubjectButtonView(subjectName: "テスト1", date: displayDate, status: .absence)
                SubjectButtonView(subjectName: "テスト2", date: displayDate, status: .tardiness)
                SubjectButtonView(subjectName: "テスト3", date: displayDate, status: .earlyDeparture)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SelectedDateDisplayView(date: .now)
}
