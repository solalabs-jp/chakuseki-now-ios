import SwiftUI

struct HistoryView: View {
    @State private var currentDate: Date = .now
    @State private var selectedDate: Date? = .now

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("履歴")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

                    CustomCalendarView(currentDate: $currentDate, selectedDate: $selectedDate)
                    
                    SelectedDateDisplayView(date: selectedDate)
                }
            }
        }
    }
}

#Preview {
    HistoryView()
}
