import SwiftUI

struct HistoryDetailView: View {
    let subjectName: String
    let date: Date
    
    // サンプルデータ
    let attendanceRecords: [AttendanceRecord] = [
        AttendanceRecord(sessionNumber: 10, date: Calendar.current.date(from: DateComponents(month: 10, day: 22)) ?? .now, status: .officialAbsence),
        AttendanceRecord(sessionNumber: 9, date: Calendar.current.date(from: DateComponents(month: 10, day: 20)) ?? .now, status: .attendance),
        AttendanceRecord(sessionNumber: 8, date: Calendar.current.date(from: DateComponents(month: 10, day: 18)) ?? .now, status: .attendance),
        AttendanceRecord(sessionNumber: 7, date: Calendar.current.date(from: DateComponents(month: 10, day: 15)) ?? .now, status: .absence),
        AttendanceRecord(sessionNumber: 6, date: Calendar.current.date(from: DateComponents(month: 10, day: 13)) ?? .now, status: .earlyDeparture)
    ]
    
    let totalSessions = 30 // 全講義回数（サンプル）
    
    var counts: [AttendanceStatus: Int] {
        Dictionary(grouping: attendanceRecords, by: { $0.status })
            .mapValues { $0.count }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // サマリーカード
                HStack(spacing: 32) {
                    // 円グラフ (Ring Chart)
                    ZStack {
                        Circle()
                            .stroke(AppColors.cardBorder.opacity(0.3), lineWidth: 12)
                        Circle()
                            .trim(from: 0, to: CGFloat(attendanceRecords.count) / CGFloat(totalSessions))
                            .stroke(AppColors.statusAttendance, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text("\(attendanceRecords.count)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            Text("/ \(totalSessions)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 100, height: 100)
                    
                    // レジェンド
                    let legendItems: [(title: String, count: Int, color: Color)] = [
                        ("出席", counts[.attendance] ?? 0, AppColors.statusAttendance),
                        ("欠席", counts[.absence] ?? 0, AppColors.statusAbsence),
                        ("遅刻", counts[.tardiness] ?? 0, AppColors.statusTardiness),
                        ("早退", counts[.earlyDeparture] ?? 0, AppColors.statusEarlyDeparture),
                        ("公欠", counts[.officialAbsence] ?? 0, AppColors.statusOfficialAbsence),
                        ("全授業", totalSessions, .primary)
                    ]
                    
                    LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 16) {
                        ForEach(legendItems, id: \.title) { item in
                            HStack(alignment: .top, spacing: 6) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                    .offset(y: 4)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Text("\(item.count)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(item.color)
                                }
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
                
                // 履歴リスト
                VStack(spacing: 16) {
                    HStack {
                        Text("授業履歴")
                            .font(.headline)
                        Spacer()
                        Text("新しい順")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(attendanceRecords.enumerated()), id: \.element.id) { index, record in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("第\(record.sessionNumber)回")
                                        .font(.system(size: 16))
                                    Text(dateFormatter.string(from: record.date))
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                
                                // ステータスバッジ
                                HStack(spacing: 4) {
                                    Image(systemName: record.status.iconName)
                                        .font(.system(size: 10))
                                    Text(record.status.rawValue)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(record.status.color)
                                .background(record.status.pillBackgroundColor)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(record.status.pillBorderColor, lineWidth: 1)
                                )
                            }
                            .padding()
                            .background(record.status.rowBackgroundColor)
                            
                            if index < attendanceRecords.count - 1 {
                                Divider()
                                    .background(AppColors.cardBorder)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )
                }
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
}

#Preview {
    NavigationStack {
        HistoryDetailView(subjectName: "数学101", date: .now)
    }
}
