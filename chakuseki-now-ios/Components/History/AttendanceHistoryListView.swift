import SwiftUI

struct AttendanceHistoryListView: View {
    let records: [AttendanceRecord]

    var body: some View {
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
                ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                    AttendanceHistoryRowView(record: record)

                    if index < records.count - 1 {
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
}

#Preview {
    AttendanceHistoryListView(records: AttendanceRecord.sampleHistory)
        .padding()
}
