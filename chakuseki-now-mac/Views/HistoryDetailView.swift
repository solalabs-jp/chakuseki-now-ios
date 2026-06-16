import SwiftUI

struct HistoryDetailView: View {
    let subjectName: String
    let date: Date

    private let attendanceRecords = AttendanceRecord.sampleHistory
    private let totalSessions = 30

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                LeadingTitleView(title: subjectName)

                AttendanceSummaryCardView(
                    records: attendanceRecords,
                    totalSessions: totalSessions
                )

                AttendanceHistoryListView(records: attendanceRecords)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "viewfinder")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        HistoryDetailView(subjectName: "数学101", date: .now)
    }
}
