import SwiftUI

enum CalendarStyle {
    static let locale = Locale(identifier: "ja_JP")
    static let weekDays = ["日", "月", "火", "水", "木", "金", "土"]
    static let selectionColor = Color.blue.opacity(0.3)
    
    static var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = locale
        return cal
    }
    
    static func monthYearString(for date: Date) -> String {
        date.formatted(.dateTime.year().month(.wide).locale(locale))
    }
}
