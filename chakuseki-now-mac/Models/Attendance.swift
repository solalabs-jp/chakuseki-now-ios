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
        case .attendance: return AppColors.statusAttendance
        case .absence: return AppColors.statusAbsence
        case .officialAbsence: return AppColors.statusOfficialAbsence
        case .bereavement: return AppColors.statusBereavement
        case .earlyDeparture: return AppColors.statusEarlyDeparture
        case .tardiness: return AppColors.statusTardiness
        }
    }
}

struct AttendanceRecord: Identifiable {
    let id = UUID()
    let sessionNumber: Int
    let date: Date
    let status: AttendanceStatus
}

extension AttendanceRecord {
    static let sampleHistory: [AttendanceRecord] = [
        sample(sessionNumber: 10, month: 10, day: 22, status: .officialAbsence),
        sample(sessionNumber: 9, month: 10, day: 20, status: .attendance),
        sample(sessionNumber: 8, month: 10, day: 18, status: .attendance),
        sample(sessionNumber: 7, month: 10, day: 15, status: .absence),
        sample(sessionNumber: 6, month: 10, day: 13, status: .earlyDeparture),
    ]

    private static func sample(
        sessionNumber: Int,
        month: Int,
        day: Int,
        status: AttendanceStatus
    ) -> AttendanceRecord {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: .now)
        let sampleDate = calendar.date(
            from: DateComponents(year: currentYear, month: month, day: day)
        ) ?? .now

        return AttendanceRecord(
            sessionNumber: sessionNumber,
            date: sampleDate,
            status: status
        )
    }
}

struct Subject: Identifiable {
    let id = UUID()
    let name: String
    var attendanceRecords: [AttendanceRecord]
}

// MARK: - Extensions
extension AttendanceStatus {
    var iconName: String {
        switch self {
        case .attendance: return "checkmark.circle.fill"
        case .absence: return "xmark.circle.fill"
        case .officialAbsence: return "checkmark.shield.fill"
        case .bereavement: return "moon.fill"
        case .earlyDeparture: return "figure.run"
        case .tardiness: return "exclamationmark.circle.fill"
        }
    }
    
    var rowBackgroundColor: Color {
        switch self {
        case .attendance: return AppColors.rowAttendanceBackground
        case .absence: return AppColors.rowAbsenceBackground
        case .officialAbsence: return AppColors.rowOfficialAbsenceBackground
        case .bereavement: return AppColors.rowBereavementBackground
        case .earlyDeparture: return AppColors.rowEarlyDepartureBackground
        case .tardiness: return AppColors.rowTardinessBackground
        }
    }
    
    var pillBackgroundColor: Color {
        switch self {
        case .attendance: return AppColors.pillAttendanceBackground
        case .absence: return AppColors.pillAbsenceBackground
        case .officialAbsence: return AppColors.pillOfficialAbsenceBackground
        case .bereavement: return AppColors.pillBereavementBackground
        case .earlyDeparture: return AppColors.pillEarlyDepartureBackground
        case .tardiness: return AppColors.pillTardinessBackground
        }
    }
    
    var pillBorderColor: Color {
        switch self {
        case .attendance: return AppColors.pillAttendanceBorder
        case .absence: return AppColors.pillAbsenceBorder
        case .officialAbsence: return AppColors.pillOfficialAbsenceBorder
        case .bereavement: return AppColors.pillBereavementBorder
        case .earlyDeparture: return AppColors.pillEarlyDepartureBorder
        case .tardiness: return AppColors.pillTardinessBorder
        }
    }
    
    var calendarColor: Color {
        switch self {
        case .attendance:
            return AppColors.statusEarlyDeparture // Green
        case .absence:
            return AppColors.statusAbsence // Red
        case .officialAbsence:
            return AppColors.statusAttendance // Blue
        case .bereavement:
            return AppColors.statusBereavement // Gray
        case .earlyDeparture, .tardiness:
            return AppColors.statusTardiness // Yellow
        }
    }
}
