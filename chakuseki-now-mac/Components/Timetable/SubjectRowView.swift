import SwiftUI

struct SubjectRowView: View {
    let subjectName: String
    let date: Date

    var body: some View {
        NavigationLink(destination: HistoryDetailView(subjectName: subjectName, date: date)) {
            HStack {
                Text(subjectName)
                Spacer()
                Text("詳細")
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    List {
        SubjectRowView(subjectName: "AWS演習", date: .now)
    }
}
