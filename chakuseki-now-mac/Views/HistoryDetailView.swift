import SwiftUI

struct HistoryDetailView: View {
    let subjectName: String
    let date: Date

    private var attendanceRecords: [AttendanceRecord] {
        AttendanceRecord.sampleHistory.map { record in
            AttendanceRecord(sessionNumber: record.sessionNumber, date: record.date, status: .bereavement)
        }
    }
    private let totalSessions = 30

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                AttendanceSummaryCardView(
                    records: attendanceRecords,
                    totalSessions: totalSessions
                )

                AttendanceHistoryListView(records: attendanceRecords)
            }
            .padding()
        }
        .navigationTitle(subjectName)
        .navigationBarTitleDisplayMode(.large)
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
