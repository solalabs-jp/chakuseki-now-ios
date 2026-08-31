import SwiftUI

struct HistoryDetailView: View {
    let subjectName: String
    let scheduleId: String

    @State private var viewModel: AttendanceHistoryViewModel

    init(subjectName: String, scheduleId: String) {
        self.subjectName = subjectName
        self.scheduleId = scheduleId
        _viewModel = State(wrappedValue: AttendanceHistoryViewModel(scheduleId: scheduleId))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)

                case .failed(let message):
                    VStack(spacing: 8) {
                        Text("読み込みに失敗しました")
                            .font(.headline)
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("再試行") {
                            Task { await viewModel.load() }
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                case .loaded:
                    if viewModel.records.isEmpty {
                        Text("この科目の出席履歴はまだありません")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                    } else {
                        AttendanceSummaryCardView(
                            records: viewModel.records,
                            totalSessions: max(viewModel.totalSessions, viewModel.records.count)
                        )

                        AttendanceHistoryListView(records: viewModel.records)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .task { await viewModel.loadIfNeeded() }
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
        HistoryDetailView(subjectName: "ITマネジメント", scheduleId: "schedule-001")
    }
}
