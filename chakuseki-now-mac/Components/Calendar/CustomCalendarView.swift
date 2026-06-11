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
                            .foregroundColor(CalendarStyle.controlColor)
                            .padding(10)
                    }

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(CalendarStyle.controlColor)
                            .padding(10)
                    }
                }
                .background(AppColors.calendarHeaderBackground)
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
                            .foregroundColor(AppColors.labelSecondary)
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek), spacing: 0) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            DayCellView(
                                date: date,
                                isSelected: isSameDay(date1: date, date2: selectedDate),
                                statuses: statuses(for: date)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            AppColors.clear
                                .frame(height: 44)
                        }
                    }
                }
            }
            
            Divider()
                .background(AppColors.cardBorder.opacity(0.3))
                .padding(.horizontal, -16)
            
            HStack(spacing: 0) {
                Spacer()
                legendItem(color: AppColors.statusEarlyDeparture, text: "出席")
                Spacer()
                legendItem(color: AppColors.statusAbsence, text: "欠席")
                Spacer()
                legendItem(color: AppColors.statusTardiness, text: "早退・中抜け")
                Spacer()
                legendItem(color: AppColors.statusAttendance, text: "公欠")
                Spacer()
            }
            .padding(.top, 4)
            .padding(.bottom, 4)
        }
        .padding()
        .background(AppColors.calendarBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
        .padding(.top, 16)
    }

    @ViewBuilder
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.brownText)
        }
    }

    private func statuses(for date: Date) -> [AttendanceStatus] {
        // デモ用に、スクショを再現するステータスを返します
        let day = calendar.component(.day, from: date)
        switch day {
        case 2, 3, 4, 10, 11, 12:
            return [.attendance]
        case 5:
            return [.absence]
        case 6:
            return [.attendance, .earlyDeparture]
        case 9:
            return [.officialAbsence]
        case 13:
            return [.attendance, .officialAbsence]
        default:
            return []
        }
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
