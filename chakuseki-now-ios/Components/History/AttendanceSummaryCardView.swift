import SwiftUI

struct AttendanceSummaryCardView: View {
    let records: [AttendanceRecord]
    let totalSessions: Int

    private var counts: [AttendanceStatus: Int] {
        Dictionary(grouping: records, by: \.status)
            .mapValues(\.count)
    }

    private var legendItems: [LegendItem] {
        [
            LegendItem(title: "出席", count: counts[.attendance] ?? 0, color: AppColors.statusAttendance),
            LegendItem(title: "欠席", count: counts[.absence] ?? 0, color: AppColors.statusAbsence),
            LegendItem(title: "遅刻", count: counts[.tardiness] ?? 0, color: AppColors.statusTardiness),
            LegendItem(title: "早退", count: counts[.earlyDeparture] ?? 0, color: AppColors.statusEarlyDeparture),
            LegendItem(title: "公欠", count: counts[.officialAbsence] ?? 0, color: AppColors.statusOfficialAbsence),
            LegendItem(title: "全授業", count: totalSessions, color: .primary)
        ]
    }

    var body: some View {
        HStack(spacing: 32) {
            AttendanceSummaryRingView(
                completedSessions: records.count,
                totalSessions: totalSessions
            )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), alignment: .leading),
                    GridItem(.flexible(), alignment: .leading)
                ],
                spacing: 16
            ) {
                ForEach(legendItems) { item in
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
    }
}

private struct AttendanceSummaryRingView: View {
    let completedSessions: Int
    let totalSessions: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.cardBorder.opacity(0.3), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.statusAttendance,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(completedSessions)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text("/ \(totalSessions)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 100, height: 100)
    }

    private var progress: CGFloat {
        guard totalSessions > 0 else {
            return 0
        }

        return CGFloat(completedSessions) / CGFloat(totalSessions)
    }
}

private struct LegendItem: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let color: Color
}

#Preview {
    AttendanceSummaryCardView(records: AttendanceRecord.sampleHistory, totalSessions: 30)
        .padding()
}
