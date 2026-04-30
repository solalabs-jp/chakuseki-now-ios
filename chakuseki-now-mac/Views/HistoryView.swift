import SwiftUI

struct HistoryView: View {
    @State private var currentDate: Date = .now
    @State private var selectedDate: Date? = nil

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
        VStack {
            if let date = date {
                Text(date.formatted(.dateTime.year().month().day().weekday(.wide).locale(Locale(identifier: "ja_JP"))))
                
                List {
                    NavigationLink(destination: HistoryDetailView(date: date)) {
                        HStack {
                            Text("AWS演習")
                            Spacer()
                            Text("詳細")
                                .foregroundColor(.accentColor)
                        }
                    }
                    NavigationLink(destination: HistoryDetailView(date: date)) {
                        HStack {
                            Text("テスト")
                            Spacer()
                            Text("詳細")
                                .foregroundColor(.accentColor)
                        }
                    }
                    NavigationLink(destination: HistoryDetailView(date: date)) {
                        HStack {
                            Text("テスト")
                            Spacer()
                            Text("詳細")
                                .foregroundColor(.accentColor)
                        }
                    }
                    NavigationLink(destination: HistoryDetailView(date: date)) {
                        HStack {
                            Text("テスト")
                            Spacer()
                            Text("詳細")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            } else {
                Text("日付が選択されていません")
            }
        }
    }
}

struct Person: Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
}

struct Department: Identifiable {
    let id = UUID()
    var name: String
    var staff: [Person]
}

struct Company {
    var departments: [Department]
}

struct HistoryDetailView: View {
    let date: Date
    
    // サンプルデータ
    let company = Company(departments: [
        Department(name: "Sales", staff: [
            Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
            Person(name: "Mei Chen", phoneNumber: "(919) 555-2481")
        ]),
        Department(name: "Engineering", staff: [
            Person(name: "Bill James", phoneNumber: "(408) 555-4450"),
            Person(name: "Anne Johnson", phoneNumber: "(417) 555-9311")
        ])
    ])
    
    var body: some View {
        VStack {
            Text(date.formatted(.dateTime.year().month().day().weekday(.wide).locale(Locale(identifier: "ja_JP"))))
            
            List {
                ForEach(company.departments) { dept in
                    Section(header: Text(dept.name)) {
                        ForEach(dept.staff) { person in
                            HStack {
                                Text(person.name)
                                Spacer()
                                Text(person.phoneNumber)
                            }
                        }
                    }
                }
            }
        }
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
