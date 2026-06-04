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
            HStack(spacing: 4) {
                Image(systemName: status.iconName)
                    .font(.system(size: 10))
                Text(status.rawValue)
                    .font(.system(size: 12, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(status.color)
            .background(status.pillBackgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(status.pillBorderColor, lineWidth: 1)
            )
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
