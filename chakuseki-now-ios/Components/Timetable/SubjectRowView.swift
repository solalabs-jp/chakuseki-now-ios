import SwiftUI

struct SubjectRowView: View {
    let subjectName: String
    let date: Date
    let timeString: String
    let status: AttendanceStatus?
    var hasEnded: Bool = false

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
            statusPill
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.labelSecondary)
        }
    }

    @ViewBuilder
    private var statusPill: some View {
        if let status {
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
        } else {
            Text(hasEnded ? "終了" : "予定")
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(AppColors.labelSecondary)
                .background(TimetableStyle.rowBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(TimetableStyle.outlineColor, lineWidth: 1)
                )
        }
    }
}

#Preview {
    List {
        SubjectRowView(subjectName: "AWS演習", date: .now, timeString: "09:15 - 10:45", status: .attendance)
    }
}
