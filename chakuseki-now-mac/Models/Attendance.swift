import Foundation
import SwiftUI

enum AttendanceStatus: String, CaseIterable, Identifiable {
    case attendance = "出席"
    case absence = "欠席"
    case officialAbsence = "公欠"
    case bereavement = "忌引き"
    case earlyDeparture = "早退"
    case tardiness = "遅刻"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .attendance: return .green
        case .absence: return .red
        case .officialAbsence: return .blue
        case .bereavement: return .gray
        case .earlyDeparture: return .orange
        case .tardiness: return .yellow
        }
    }
}

struct AttendanceRecord: Identifiable {
    let id = UUID()
    let sessionNumber: Int
    let date: Date
    let status: AttendanceStatus
}

struct Subject: Identifiable {
    let id = UUID()
    let name: String
    var attendanceRecords: [AttendanceRecord]
}
