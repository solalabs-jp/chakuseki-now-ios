import SwiftUI

struct HistoryView: View {
    @State private var currentDate: Date = .now
    @State private var selectedDate: Date? = .now

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("履歴を確認しよう")
                        .font(.system(size: 24, weight: .bold))
                        .kerning(0.4)
                        .foregroundColor(AppColors.labelPrimary)
                        .frame(width: 241, height: 41, alignment: .topLeading)
                    
                    Spacer()
                }

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

