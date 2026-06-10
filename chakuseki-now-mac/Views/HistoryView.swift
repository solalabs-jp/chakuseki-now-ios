import SwiftUI

struct HistoryView: View {
    @State private var currentDate: Date = .now
    @State private var selectedDate: Date? = .now

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                LeadingTitleView(title: "履歴を確認しよう")

                ScrollView {
                    VStack(spacing: 0) {
                        CustomCalendarView(currentDate: $currentDate, selectedDate: $selectedDate)
                        
                        SelectedDateDisplayView(date: selectedDate)
                    }
                }
            }
            .padding(.top, 1.5)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    HistoryView()
}
