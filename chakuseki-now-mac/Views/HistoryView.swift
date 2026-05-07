import SwiftUI
import Charts

struct HistoryView: View {
    @State private var currentDate: Date = .now
    @State private var selectedDate: Date? = .now

    var body: some View {
        NavigationStack {
            VStack {
                Text("履歴")

                CustomCalendarView(currentDate: $currentDate, selectedDate: $selectedDate)
                
                SelectedDateDisplayView(date: selectedDate)
            }
        }
    }
}

struct SelectedDateDisplayView: View {
    let date: Date?
    
    var body: some View {
        let displayDate = date ?? .now
        VStack {
            Text(displayDate.formatted(.dateTime.year().month().day().weekday(.wide).locale(Locale(identifier: "ja_JP"))))
            
            List {
                NavigationLink(destination: HistoryDetailView(subjectName: "AWS演習", date: displayDate)) {
                    HStack {
                        Text("AWS演習")
                        Spacer()
                        Text("詳細")
                            .foregroundColor(.accentColor)
                    }
                }
                NavigationLink(destination: HistoryDetailView(subjectName: "テスト", date: displayDate)) {
                    HStack {
                        Text("テスト")
                        Spacer()
                        Text("詳細")
                            .foregroundColor(.accentColor)
                    }
                }
                NavigationLink(destination: HistoryDetailView(subjectName: "テスト", date: displayDate)) {
                    HStack {
                        Text("テスト")
                        Spacer()
                        Text("詳細")
                            .foregroundColor(.accentColor)
                    }
                }
                NavigationLink(destination: HistoryDetailView(subjectName: "テスト", date: displayDate)) {
                    HStack {
                        Text("テスト")
                        Spacer()
                        Text("詳細")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}

struct HistoryDetailView: View {
    let subjectName: String
    let date: Date
    
    // サンプルデータ
    let attendanceRecords: [AttendanceRecord] = [
        AttendanceRecord(sessionNumber: 1, date: .now, status: .attendance),
        AttendanceRecord(sessionNumber: 2, date: .now, status: .tardiness),
        AttendanceRecord(sessionNumber: 3, date: .now, status: .earlyDeparture),
        AttendanceRecord(sessionNumber: 4, date: .now, status: .absence),
        AttendanceRecord(sessionNumber: 5, date: .now, status: .officialAbsence),
        AttendanceRecord(sessionNumber: 6, date: .now, status: .bereavement),
        AttendanceRecord(sessionNumber: 7, date: .now, status: .attendance),
        AttendanceRecord(sessionNumber: 8, date: .now, status: .attendance)
    ]
    
    let totalSessions = 15 // 全講義回数（サンプル）
    
    var statusSummary: [(status: AttendanceStatus, count: Int)] {
        let counts = Dictionary(grouping: attendanceRecords, by: { $0.status })
            .mapValues { $0.count }
        return AttendanceStatus.allCases.compactMap { status in
            guard let count = counts[status], count > 0 else { return nil }
            return (status, count)
        }
    }
    
    var body: some View {
        VStack {
            Text(subjectName)
            
            Chart(statusSummary, id: \.status) { item in
                SectorMark(
                    angle: .value("回数", item.count),
                    innerRadius: .ratio(0.5)
                )
                .foregroundStyle(by: .value("状態", item.status.rawValue))
            }
            .frame(height: 200)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let plotFrame = chartProxy.plotFrame {
                        let frame = geometry[plotFrame]
                        Text("\(attendanceRecords.count) / \(totalSessions)")
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            
            List {
                ForEach(attendanceRecords.reversed()) { record in
                    HStack {
                        Text("第\(record.sessionNumber)回")
                        Spacer()
                        Text(record.status.rawValue)
                    }
                }
            }
        }
        .navigationTitle("出席状況")
    }
}

struct CustomCalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "ja_JP")
        return cal
    }()
    
    private let daysInWeek = 7
    private let weekDays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Text("< 前月")
                }

                Spacer()

                Text(currentDate.formatted(.dateTime.year().month(.wide).locale(Locale(identifier: "ja_JP"))))

                Spacer()

                Button(action: nextMonth) {
                    Text("次月 >")
                }
            }

            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
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
                    }
                }
            }
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

struct DayCellView: View {
    let date: Date
    let isSelected: Bool

    private let calendar = Calendar.current

    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
    }
}

#Preview {
    HistoryView()
}
