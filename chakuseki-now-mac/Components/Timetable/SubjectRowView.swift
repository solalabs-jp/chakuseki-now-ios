import SwiftUI

struct SubjectRowView: View {
    let subjectName: String
    let date: Date
    let status: AttendanceStatus

    var body: some View {
        HStack {
            Text(subjectName)
                .font(.body)
            Spacer()
            Text(status.rawValue)
                .font(.body)
                .foregroundColor(status.color)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    List {
        SubjectRowView(subjectName: "AWS演習", date: .now, status: .attendance)
    }
}
