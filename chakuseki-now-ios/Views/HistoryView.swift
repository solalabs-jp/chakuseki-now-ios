import SwiftUI

struct HistoryView: View {
    @State private var currentDate: Date = .now
    @State private var selectedDate: Date? = .now
    @State private var timetableViewModel = TimetableViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                LeadingTitleView(title: "履歴を確認しよう")

                ScrollView {
                    VStack(spacing: 40) {
                        CustomCalendarView(currentDate: $currentDate, selectedDate: $selectedDate)

                        SelectedDateDisplayView(
                            date: selectedDate,
                            entries: timetableViewModel.entries(on: selectedDate ?? .now),
                            state: timetableViewModel.state
                        )
                    }
                }
            }
            .padding(.top, 1.5)
            .padding(.horizontal)
            .padding(.bottom)
            .task { await timetableViewModel.loadIfNeeded() }
        }
    }
}

#Preview {
    HistoryView()
}
