import SwiftUI

struct CustomCalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?

    private let calendar = CalendarStyle.calendar
    private let daysInWeek = 7
    private let weekDays = CalendarStyle.weekDays

    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .padding()
                }

                Spacer()

                Text(CalendarStyle.monthYearString(for: currentDate))
                    .font(.headline)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            }

            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek)) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCellView(date: date, isSelected: isSameDay(date1: date, date2: selectedDate))
                            .onTapGesture {
                                selectedDate = date
                            }
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding()
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
            return []
        }
        
        let startOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var dates: [Date?] = []
        
        let emptySpaces = firstWeekday - 1
        for _ in 0..<emptySpaces {
            dates.append(nil)
        }
        
        guard let rangeOfDays = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return dates
        }
        
        for dayOffset in 0..<rangeOfDays.count {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        while dates.count % 7 != 0 {
            dates.append(nil)
        }
        
        return dates
    }

    private func isSameDay(date1: Date, date2: Date?) -> Bool {
        guard let date2 = date2 else { return false }
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}
