import SwiftUI
import Charts

struct HistoryDetailView: View {
    let subjectName: String
    let date: Date
    
    // サンプルデータ
    let attendanceRecords: [AttendanceRecord] = [
        AttendanceRecord(sessionNumber: 1, date: .now, status: .attendance),
        AttendanceRecord(sessionNumber: 2, date: .now, status: .tardiness),
        AttendanceRecord(sessionNumber: 3, date: .now, status: .earlyDeparture),
        AttendanceRecord(sessionNumber: 4, date: .now, status: .absence),
        AttendanceRecord(sessionNumber: 5, date: .now, status: .officialAbsence),
        AttendanceRecord(sessionNumber: 6, date: .now, status: .bereavement),
        AttendanceRecord(sessionNumber: 7, date: .now, status: .attendance),
        AttendanceRecord(sessionNumber: 8, date: .now, status: .attendance)
    ]
    
    let totalSessions = 15 // 全講義回数（サンプル）
    
    var statusSummary: [(status: AttendanceStatus, count: Int)] {
        let counts = Dictionary(grouping: attendanceRecords, by: { $0.status })
            .mapValues { $0.count }
        return AttendanceStatus.allCases.compactMap { status in
            guard let count = counts[status], count > 0 else { return nil }
            return (status, count)
        }
    }
    
    var body: some View {
        VStack {
            Text(subjectName)
                .font(.title)
                .padding()
            
            Chart(statusSummary, id: \.status) { item in
                SectorMark(
                    angle: .value("回数", item.count),
                    innerRadius: .ratio(0.5)
                )
                .foregroundStyle(by: .value("状態", item.status.rawValue))
            }
            .frame(height: 200)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let plotFrame = chartProxy.plotFrame {
                        let frame = geometry[plotFrame]
                        Text("\(attendanceRecords.count) / \(totalSessions)")
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            
            List {
                ForEach(attendanceRecords.reversed()) { record in
                    HStack {
                        Text("第\(record.sessionNumber)回")
                        Spacer()
                        Text(record.status.rawValue)
                            .foregroundColor(record.status.color)
                    }
                }
            }
        }
        .navigationTitle("出席状況")
    }
}

#Preview {
    NavigationStack {
        HistoryDetailView(subjectName: "AWS演習", date: .now)
    }
}
