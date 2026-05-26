import SwiftUI

struct SubjectRowView: View {
    let subjectName: String
    let date: Date
    let timeString: String
    let status: AttendanceStatus

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subjectName)
                    .font(.body)
                    .foregroundColor(AppColors.labelPrimary)
                Text(timeString)
                    .font(.caption)
                    .foregroundColor(TimetableStyle.timeColor)
            }
            Spacer()
            Text(status.rawValue)
                .font(.body)
                .foregroundColor(status.color)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.labelSecondary)
        }
    }
}

#Preview {
    List {
        SubjectRowView(subjectName: "AWS演習", date: .now, timeString: "09:15 - 10:45", status: .attendance)
    }
}
