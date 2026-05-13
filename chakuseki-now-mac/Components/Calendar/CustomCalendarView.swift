import SwiftUI

struct CustomCalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?

    private let calendar = CalendarStyle.calendar
    private let daysInWeek = 7
    private let weekDays = CalendarStyle.weekDays

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(CalendarStyle.monthYearString(for: currentDate))
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()
                
                HStack(spacing: 0) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(10)
                    }

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(10)
                    }
                }
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)

            VStack(spacing: 8) {
                HStack {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek), spacing: 0) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            DayCellView(
                                date: date,
                                isSelected: isSameDay(date1: date, date2: selectedDate),
                                hasEvent: shouldShowEvent(for: date)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            Color.clear
                                .frame(height: 44)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red, lineWidth: 1)
        )
        .padding()
    }

    private func shouldShowEvent(for date: Date) -> Bool {
        // デモ用に、偶数の日に印を表示するようにします
        let day = calendar.component(.day, from: date)
        return day % 3 == 0
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
